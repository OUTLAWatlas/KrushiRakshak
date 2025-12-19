import 'dart:io';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OCRService {
  final TextRecognizer _recognizer = TextRecognizer();

  Future<String> scanText(File imageFile) async {
    final input = InputImage.fromFile(imageFile);
    final result = await _recognizer.processImage(input);
    return result.text;
  }

  void dispose() {
    _recognizer.close();
  }
}
