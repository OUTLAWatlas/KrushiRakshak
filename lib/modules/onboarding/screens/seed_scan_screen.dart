import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../../../core/services/database_service.dart';

class SeedScanScreen extends StatefulWidget {
  const SeedScanScreen({super.key});

  @override
  State<SeedScanScreen> createState() => _SeedScanScreenState();
}

class _SeedScanScreenState extends State<SeedScanScreen> {
  CameraController? _cameraController;
  late final TextRecognizer _textRecognizer;
  bool _isProcessing = false;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    _textRecognizer = TextRecognizer();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;
      final controller = CameraController(
        cameras.first,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await controller.initialize();
      setState(() {
        _cameraController = controller;
        _isCameraInitialized = true;
      });
    } catch (_) {
      // Handle camera permission/initialization errors in production.
    }
  }

  Future<void> _captureAndRecognize() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }
    if (_isProcessing) return;

    setState(() => _isProcessing = true);
    try {
      final xFile = await _cameraController!.takePicture();
      final inputImage = InputImage.fromFile(File(xFile.path));
      final recognizedText = await _textRecognizer.processImage(inputImage);
      final detection = _parseText(recognizedText.text);
      if (!mounted) return;

      await _showDetectionDialog(detection);
    } catch (_) {
      // Silently ignore for now.
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  _DetectionResult _parseText(String text) {
    final lower = text.toLowerCase();
    if (lower.contains('rasi') || lower.contains('659')) {
      return _DetectionResult(
        brand: 'Rasi',
        variety: 'Hybrid Bt Cotton',
        durationDays: 160,
      );
    }
    if (lower.contains('mahyco')) {
      return _DetectionResult(
        brand: 'Mahyco',
        variety: 'Standard Cotton',
        durationDays: 150,
      );
    }
    return _DetectionResult(brand: 'Unknown', variety: 'Cotton', durationDays: 150);
  }

  Future<void> _showDetectionDialog(_DetectionResult detection) async {
    final db = DatabaseService();
    await db.init();

    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Seed Detected'),
          content: Text(
            'Brand: ${detection.brand}\nVariety: ${detection.variety}\nDuration: ${detection.durationDays} days',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Scan Again'),
            ),
            ElevatedButton(
              onPressed: () async {
                await db.saveUserProfile({
                  'name': '',
                  'crop': 'Cotton',
                  'variety': detection.variety,
                  'sowingDate': DateTime.now().toIso8601String(),
                  'duration': detection.durationDays,
                });
                if (!mounted) return;
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacementNamed('/dashboard');
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _textRecognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seed Scan'),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isCameraInitialized
                ? CameraPreview(_cameraController!)
                : const Center(child: CircularProgressIndicator()),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isProcessing ? null : _captureAndRecognize,
                  icon: const Icon(Icons.camera_alt),
                  label: Text(_isProcessing ? 'Processing...' : 'Capture Seed Packet'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetectionResult {
  _DetectionResult({
    required this.brand,
    required this.variety,
    required this.durationDays,
  });

  final String brand;
  final String variety;
  final int durationDays;
}
