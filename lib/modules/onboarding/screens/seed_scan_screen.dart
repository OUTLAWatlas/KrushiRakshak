import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../data/crop_data.dart';
import '../../../core/services/database_service.dart';
import '../../../core/services/ocr_service.dart';
import '../../../core/services/localization_service.dart';

class SeedScanScreen extends StatefulWidget {
  const SeedScanScreen({super.key});

  @override
  State<SeedScanScreen> createState() => _SeedScanScreenState();
}

class _SeedScanScreenState extends State<SeedScanScreen> {
  CameraController? _cameraController;
  OCRService? _ocrService;
  bool _isProcessing = false;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    _ocrService = OCRService();
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
      final file = File(xFile.path);
      final recognizedText = await (_ocrService?.scanSeedPacket(file) ?? Future.value('OCR Unsupported'));
      if (!mounted) return;

      await _showConfirmationDialog(recognizedText);
    } catch (_) {
      // Silently ignore for now.
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _showConfirmationDialog(String detectedText) async {
    // 1. Identify Crop (Simple Logic for MVP)
    String cropId = 'cotton'; // Default
    String cropName = 'Cotton';

    if (detectedText.toLowerCase().contains("soy")) {
      cropId = 'soybean';
      cropName = 'Soybean';
    } else if (detectedText.toLowerCase().contains("wheat")) {
      cropId = 'wheat';
      cropName = 'Wheat';
    }

    // 2. Get the "Smart Guess" Date
    DateTime estimatedDate = CropData.estimateSowingDate(cropId);

    // We store this in a temporary variable so the user can change it
    DateTime selectedDate = estimatedDate;

    await showDialog(
      context: context,
      barrierDismissible: false, // Force them to choose
      builder: (context) {
        return StatefulBuilder( // Needed to update the Date Text inside Dialog
          builder: (context, setDialogState) {
            final loc = Provider.of<LocalizationService>(context);
            final guessedText = loc.translate('we_guessed').replaceAll('{crop}', cropName);

            return AlertDialog(
              title: Text(loc.translate('confirm_crop_details')),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Crop Detection
                  Text('${loc.translate('detected')}: $cropName', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text(loc.translate('seed_variety_hybrid'), style: const TextStyle(color: Colors.grey)),
                  const Divider(height: 30),

                  // The "Smart Date" Section
                  Text(loc.translate('sowing_date'), style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2023),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setDialogState(() {
                          selectedDate = picked;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.green),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.green.withOpacity(0.1)
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormat('dd MMMM yyyy').format(selectedDate),
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const Icon(Icons.calendar_today, color: Colors.green),
                        ],
                      ),
                    ),
                  ),

                  // "Smart Guess" Explanation
                  if (selectedDate != DateTime.now())
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        guessedText,
                        style: TextStyle(fontSize: 11, color: Colors.blue[800], fontStyle: FontStyle.italic),
                      ),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(loc.translate('retake_photo'), style: const TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Pass the CORRECTED date to your save function
                    _saveAndContinue(cropName, cropId, selectedDate);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: Text(loc.translate('confirm_and_start'), style: const TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _saveAndContinue(String name, String id, DateTime date) async {
    final db = DatabaseService();
    await db.init();
    final profile = {
      'crop': name,
      'cropId': id,
      'variety': 'Hybrid Bt',
      'duration': id == 'cotton' ? 160 : 100,
      'sowingDate': date.toIso8601String(), // Uses the historic date!
      'userName': 'Farmer',
    };

    await db.saveUserProfile(profile);

    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (route) => false);
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _ocrService?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocalizationService>();

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('seed_scan_title')),
        actions: [
          IconButton(
            tooltip: loc.translate('skip_onboarding'),
            icon: const Icon(Icons.skip_next_outlined),
            onPressed: () async {
              // Create a default profile and proceed to dashboard (useful for testing).
              final db = DatabaseService();
              await db.init();
              final defaultProfile = {
                'crop': 'Cotton',
                'cropId': 'cotton',
                'variety': 'Hybrid Bt',
                'duration': 160,
                'sowingDate': DateTime.now().toIso8601String(),
                'userName': 'Farmer',
              };
              await db.saveUserProfile(defaultProfile);
              if (!mounted) return;
              Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (route) => false);
            },
          ),
        ],
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
                  label: Text(_isProcessing ? loc.translate('processing') : loc.translate('capture_seed_packet')),
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
