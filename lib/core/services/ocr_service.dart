import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OCRService {
  final TextRecognizer _recognizer = TextRecognizer();

  Future<String> scanSeedPacket(InputImage image) async {
    final result = await _recognizer.processImage(image);
    final text = result.text.toLowerCase();
    if (text.contains('rasi')) return 'Rasi';
    if (text.contains('mahyco')) return 'Mahyco';
    if (text.contains('659')) return '659';
    return text.isNotEmpty ? text : 'Unknown';
  }

  void dispose() {
    _recognizer.close();
  }
}
