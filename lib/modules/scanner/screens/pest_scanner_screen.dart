  import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class PestScannerScreen extends StatefulWidget {
  const PestScannerScreen({super.key});

  @override
  State<PestScannerScreen> createState() => _PestScannerScreenState();
}

class _PestScannerScreenState extends State<PestScannerScreen>
    with SingleTickerProviderStateMixin {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isScanning = false;
  Map<String, dynamic>? _result;
  late final AnimationController _scanLineController;
  Interpreter? _interpreter;
  List<String> _labels = const [];

  @override
  void initState() {
    super.initState();
    _scanLineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _initializeCamera();
    _loadModel();
  }

  Future<void> _loadModel() async {
    try {
      final interpreter = await Interpreter.fromAsset('assets/models/pest_model.tflite');
      final labels = await _loadLabels('assets/models/pest_labels.txt');
      setState(() {
        _interpreter = interpreter;
        _labels = labels;
      });
    } catch (_) {
      // In production, surface an error or fallback UI.
    }
  }

  Future<List<String>> _loadLabels(String assetPath) async {
    final raw = await rootBundle.loadString(assetPath);
    return raw.split('\n').where((line) => line.trim().isNotEmpty).toList();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;
      final camera = cameras.first;
      final controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
      );
      await controller.initialize();
      await controller.startImageStream(_onCameraImage);
      setState(() {
        _cameraController = controller;
        _isCameraInitialized = true;
      });
    } catch (e) {
      // For production, handle permissions and errors more robustly.
    }
  }

  Future<void> _onCameraImage(CameraImage image) async {
    if (_isScanning) return;
    await runModelOnFrame(image);
  }

  Future<void> runModelOnFrame(CameraImage image) async {
    if (_interpreter == null) return;
    _isScanning = true;
    try {
      final inputTensor = _interpreter!.getInputTensor(0);
      final shape = inputTensor.shape; // e.g., [1, 224, 224, 3]
      final targetH = shape[1];
      final targetW = shape[2];

      final input = _convertCameraImageToInput(image, targetW, targetH);
      final outputShape = _interpreter!.getOutputTensor(0).shape; // [1, numLabels]
      final numLabels = outputShape.last;
      final output = List.generate(1, (_) => List.filled(numLabels, 0.0));

      _interpreter!.run(input, output);

      final scores = output.first;
      final bestIndex = _argMax(scores);
      final confidence = scores[bestIndex];
      if (confidence >= 0.8) {
        setState(() {
          _result = {
            'label': bestIndex < _labels.length ? _labels[bestIndex] : 'Unknown',
            'confidence': confidence,
          };
        });
        _showResultSheet();
      }
    } catch (_) {
      // Silently ignore frame errors to keep scanning.
    } finally {
      _isScanning = false;
    }
  }

  List<List<List<List<double>>>> _convertCameraImageToInput(
    CameraImage image,
    int targetW,
    int targetH,
  ) {
    // Convert YUV420 to RGB888
    final rgbBytes = _yuv420ToRgb(image);
    final resized = _resizeRgb(
      rgbBytes,
      image.width,
      image.height,
      targetW,
      targetH,
    );

    int idx = 0;
    return List.generate(
      1,
      (_) => List.generate(
        targetH,
        (y) => List.generate(
          targetW,
          (x) {
            final r = resized[idx++] / 255.0;
            final g = resized[idx++] / 255.0;
            final b = resized[idx++] / 255.0;
            return [r, g, b];
          },
        ),
      ),
    );
  }

  int _argMax(List<double> list) {
    var bestIdx = 0;
    var bestScore = -double.infinity;
    for (var i = 0; i < list.length; i++) {
      if (list[i] > bestScore) {
        bestScore = list[i];
        bestIdx = i;
      }
    }
    return bestIdx;
  }

  Uint8List _yuv420ToRgb(CameraImage image) {
    final width = image.width;
    final height = image.height;
    final uvRowStride = image.planes[1].bytesPerRow;
    final uvPixelStride = image.planes[1].bytesPerPixel ?? 1;

    final out = Uint8List(width * height * 3);
    var outIndex = 0;

    for (int y = 0; y < height; y++) {
      final uvRow = uvRowStride * (y >> 1);
      for (int x = 0; x < width; x++) {
        final uvIndex = uvRow + (x >> 1) * uvPixelStride;
        final yp = image.planes[0].bytes[y * image.planes[0].bytesPerRow + x];
        final up = image.planes[1].bytes[uvIndex];
        final vp = image.planes[2].bytes[uvIndex];

        final r = (yp + 1.403 * (vp - 128)).clamp(0, 255).toInt();
        final g = (yp - 0.344 * (up - 128) - 0.714 * (vp - 128)).clamp(0, 255).toInt();
        final b = (yp + 1.770 * (up - 128)).clamp(0, 255).toInt();

        out[outIndex++] = r;
        out[outIndex++] = g;
        out[outIndex++] = b;
      }
    }
    return out;
  }

  Uint8List _resizeRgb(
    Uint8List rgbBytes,
    int srcW,
    int srcH,
    int dstW,
    int dstH,
  ) {
    final out = Uint8List(dstW * dstH * 3);
    for (int y = 0; y < dstH; y++) {
      for (int x = 0; x < dstW; x++) {
        final srcX = (x * srcW / dstW).floor();
        final srcY = (y * srcH / dstH).floor();
        final srcIndex = (srcY * srcW + srcX) * 3;
        final dstIndex = (y * dstW + x) * 3;
        out[dstIndex] = rgbBytes[srcIndex];
        out[dstIndex + 1] = rgbBytes[srcIndex + 1];
        out[dstIndex + 2] = rgbBytes[srcIndex + 2];
      }
    }
    return out;
  }

  void _showResultSheet() {
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        final label = _result?['label']?.toString() ?? 'Unknown';
        final conf = ((_result?['confidence'] as double?) ?? 0) * 100;
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text('Confidence: ${conf.toStringAsFixed(1)}%'),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // Navigate to cure/solution screen.
                  },
                  child: const Text('View Cure'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _scanLineController.dispose();
    _cameraController?.dispose();
    _interpreter?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pest Scanner'),
      ),
      body: _isCameraInitialized
          ? Stack(
              children: [
                Positioned.fill(
                  child: CameraPreview(_cameraController!),
                ),
                Positioned.fill(
                  child: CustomPaint(
                    painter: _ScannerOverlayPainter(
                      animationValue: _scanLineController.value,
                    ),
                  ),
                ),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 24,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_cameraController == null) return;
                      if (_cameraController!.value.isStreamingImages) return;
                      await _cameraController!.startImageStream(_onCameraImage);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Scan Now'),
                  ),
                ),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}

class _ScannerOverlayPainter extends CustomPainter {
  _ScannerOverlayPainter({required this.animationValue});

  final double animationValue;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final frameSize = Size(size.width * 0.75, size.width * 0.75 * 0.75);
    final frameOffset = Offset(
      (size.width - frameSize.width) / 2,
      (size.height - frameSize.height) / 3,
    );
    final rect = frameOffset & frameSize;

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(16)),
      paint,
    );

    final scanLinePaint = Paint()
      ..color = Colors.greenAccent.withOpacity(0.7)
      ..strokeWidth = 3;

    final y = rect.top + rect.height * animationValue;
    canvas.drawLine(
      Offset(rect.left + 8, y),
      Offset(rect.right - 8, y),
      scanLinePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ScannerOverlayPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
