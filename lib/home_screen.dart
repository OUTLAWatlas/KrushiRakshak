import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'services/ocr_service.dart';
import 'services/tflite_service.dart';
import 'services/tts_service.dart';

const Map<String, Map<String, String>> expertData = {
  "0 Corn and Maize Blight ": {"action": "Apply fungicides.", "severity": "high"},
  "1 Corn and Maize Common Rust": {"action": "Plant resistant hybrids.", "severity": "medium"},
  "2 Corn and Maize Gray Leaf Spot ": {"action": "Rotate crops.", "severity": "medium"},
  "3 Corn and Maize Healthy ": {"action": "No action needed.", "severity": "low"},
  "4 Soyabean Pest Attack  ": {"action": "Spray Neem oil.", "severity": "high"},
  "5 Soyabean Frog leaf eye ": {"action": "Fungicide at R3 stage.", "severity": "medium"},
  "6 Soyabean Spectoria Brown Spot": {"action": "Monitor lower canopy.", "severity": "medium"},
  "7 Soyabean Healthy": {"action": "Optimal growth.", "severity": "low"},
  "8 Soyabean Rust ": {"action": "CRITICAL: Apply triazole fungicides.", "severity": "critical"},
  "9 Soyabean Mosaic": {"action": "Remove infected plants.", "severity": "critical"},
  "10 cotton bacterial blight ": {"action": "Use acid-delinted seeds.", "severity": "high"},
  "11 cotton curl virus ": {"action": "Control whitefly vector.", "severity": "critical"},
  "12 cotton fussarium wilt ": {"action": "Use resistant varieties.", "severity": "high"},
  "13 cotton healthy ": {"action": "Healthy boll development.", "severity": "low"},
  "14 cotton red cotton leaf ": {"action": "Check Magnesium levels.", "severity": "medium"}
};

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final tabs = [
      const CropDoctorTab(),
      const SeedScannerTab(),
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(child: tabs[_tabIndex]),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.greenAccent,
        unselectedItemColor: Colors.white70,
        currentIndex: _tabIndex,
        onTap: (i) => setState(() => _tabIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.agriculture), label: 'Crop Doctor'),
          BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner), label: 'Seed Scanner'),
        ],
      ),
    );
  }
}

class CropDoctorTab extends StatefulWidget {
  const CropDoctorTab({super.key});

  @override
  State<CropDoctorTab> createState() => _CropDoctorTabState();
}

class _CropDoctorTabState extends State<CropDoctorTab> {
  CameraController? _controller;
  bool _isDetecting = false;
  TFLiteDetection? _lastDetection;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cams = await availableCameras();
      final cam = cams.first;
      _controller = CameraController(cam, ResolutionPreset.medium, enableAudio: false);
      await _controller!.initialize();
      await context.read<TFLiteService>().loadModel();
      await _controller!.startImageStream(_processCameraImage);
      setState(() {});
    } catch (e) {
      debugPrint('Camera init error: $e');
    }
  }

  Future<void> _processCameraImage(CameraImage image) async {
    if (_isDetecting) return;
    _isDetecting = true;
    try {
      final result = await context.read<TFLiteService>().runOnFrame(image);
      if (result != null && result.confidence >= 0.8) {
        if (_lastDetection?.label != result.label || (_lastDetection?.confidence ?? 0) != result.confidence) {
          _lastDetection = result;
          _showDetectionSheet(result);
        }
      }
    } catch (e) {
      debugPrint('Detection error: $e');
    } finally {
      _isDetecting = false;
    }
  }

  void _showDetectionSheet(TFLiteDetection detection) {
    final data = expertData[detection.label.trim()];
    if (data == null) return;

    final severity = data['severity'] ?? 'low';
    final action = data['action'] ?? '';

    // Critical speak
    if (severity.toLowerCase() == 'critical') {
      context.read<TtsService>().speak('Alert. Disease detected.');
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Disease', style: TextStyle(color: Colors.greenAccent[400], fontSize: 14)),
            const SizedBox(height: 6),
            Text(detection.label, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Confidence: ${(detection.confidence * 100).toStringAsFixed(1)}%', style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 12),
            Text('Advice', style: TextStyle(color: Colors.greenAccent[400], fontSize: 14)),
            const SizedBox(height: 6),
            Text(action, style: const TextStyle(color: Colors.white, fontSize: 16)),
            const SizedBox(height: 12),
            Chip(
              label: Text('Severity: $severity', style: const TextStyle(color: Colors.white)),
              backgroundColor: _severityColor(severity),
            ),
          ],
        ),
      ),
    );
  }

  Color _severityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
      case 'high':
        return Colors.redAccent;
      case 'medium':
        return Colors.orangeAccent;
      default:
        return Colors.greenAccent;
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Column(
        children: [
          const SizedBox(height: 8),
          Text('Crop Doctor', style: TextStyle(color: Colors.greenAccent[400], fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Expanded(
            child: _controller == null || !_controller!.value.isInitialized
                ? const Center(child: CircularProgressIndicator(color: Colors.greenAccent))
                : CameraPreview(_controller!),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class SeedScannerTab extends StatefulWidget {
  const SeedScannerTab({super.key});

  @override
  State<SeedScannerTab> createState() => _SeedScannerTabState();
}

class _SeedScannerTabState extends State<SeedScannerTab> {
  final ImagePicker _picker = ImagePicker();
  String _status = 'No scan yet';
  String _colorStatus = 'grey';

  Future<void> _captureAndScan() async {
    final image = await _picker.pickImage(source: ImageSource.camera);
    if (image == null) return;

    final text = await context.read<OCRService>().scanText(File(image.path));
    final lower = text.toLowerCase();

    if (lower.contains('expired') || lower.contains('use by 2023') || lower.contains('2022')) {
      setState(() {
        _status = 'EXPIRED';
        _colorStatus = 'red';
      });
    } else if (lower.contains('purity') || lower.contains('germination')) {
      setState(() {
        _status = 'VERIFIED';
        _colorStatus = 'green';
      });
    } else {
      setState(() {
        _status = 'UNKNOWN / SCAN AGAIN';
        _colorStatus = 'orange';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Seed Scanner', style: TextStyle(color: Colors.greenAccent[400], fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.grey[900],
                border: Border.all(color: Colors.greenAccent.withOpacity(0.4)),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Status:', style: TextStyle(color: Colors.greenAccent[400], fontSize: 16)),
                  const SizedBox(height: 8),
                  Chip(
                    label: Text(_status, style: const TextStyle(color: Colors.white)),
                    backgroundColor: _chipColor(_colorStatus),
                  ),
                  const SizedBox(height: 12),
                  const Text('Logic:', style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 4),
                  const Text('- EXPIRED if contains: Expired / Use By 2023 / 2022', style: TextStyle(color: Colors.white54)),
                  const Text('- VERIFIED if contains: Purity / Germination', style: TextStyle(color: Colors.white54)),
                  const Text('- Otherwise: UNKNOWN / SCAN AGAIN', style: TextStyle(color: Colors.white54)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.greenAccent[400],
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: _captureAndScan,
            icon: const Icon(Icons.camera_alt),
            label: const Text('Capture Seed Packet'),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Color _chipColor(String key) {
    switch (key) {
      case 'red':
        return Colors.redAccent;
      case 'green':
        return Colors.green;
      case 'orange':
        return Colors.orangeAccent;
      default:
        return Colors.grey;
    }
  }
}
