import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:tflite/tflite.dart';

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
    await Tflite.close();
    await Tflite.loadModel(
      model: 'assets/models/pest_model.tflite',
      labels: 'assets/models/pest_labels.txt',
    );
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
    _isScanning = true;
    try {
      final bytesList = image.planes.map((plane) => plane.bytes).toList();
      final results = await Tflite.runModelOnFrame(
        bytesList: bytesList,
        imageHeight: image.height,
        imageWidth: image.width,
        numResults: 1,
        threshold: 0.05,
        asynch: true,
      );

      if (results != null && results.isNotEmpty) {
        final first = results.first as Map;
        final confidence = (first['confidence'] as double?) ?? 0.0;
        if (confidence >= 0.8) {
          setState(() {
            _result = {
              'label': first['label'] ?? 'Unknown',
              'confidence': confidence,
            };
          });
          _showResultSheet();
        }
      }
    } catch (_) {
      // Silently ignore frame errors to keep scanning.
    } finally {
      _isScanning = false;
    }
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
    Tflite.close();
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
