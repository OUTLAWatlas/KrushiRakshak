import 'dart:io';

import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform, kIsWeb;
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OCRService {
  final TextRecognizer? _recognizer;

  OCRService() : _recognizer = (!_isSupportedPlatform()) ? null : TextRecognizer();

  static bool _isSupportedPlatform() {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS;
  }

  Future<String> scanSeedPacket(File imageFile) async {
    if (_recognizer == null) return 'OCR Unsupported';
    final inputImage = InputImage.fromFile(imageFile);
    final result = await _recognizer!.processImage(inputImage);
    final text = result.text.toLowerCase();
    if (text.contains('rasi')) return 'Rasi';
    if (text.contains('mahyco')) return 'Mahyco';
    if (text.contains('659')) return '659';
    return text.isNotEmpty ? text : 'Unknown';
  }

  void dispose() {
    try {
      _recognizer?.close();
    } catch (_) {
      // Ignore platform errors when plugin not implemented on this platform
    }
  }
}
