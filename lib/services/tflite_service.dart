import 'dart:async';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:tflite/tflite.dart';
import '../core/services/dialect_service.dart';

class TFLiteDetection {
  TFLiteDetection({required this.label, required this.confidence});

  final String label;
  final double confidence; // 0-1
}

class TFLiteService {
  bool _loaded = false;

  Future<void> loadModel({
    String model = 'assets/models/model_quantized.tflite',
    String labels = 'assets/models/labels.txt',
  }) async {
    if (_loaded) return;
    await Tflite.close();
    final res = await Tflite.loadModel(model: model, labels: labels);
    if (res != null) {
      _loaded = true;
    }
  }

  Future<TFLiteDetection?> runOnFrame(CameraImage image) async {
    if (!_loaded) return null;

    final results = await Tflite.runModelOnFrame(
      bytesList: image.planes.map((p) => p.bytes).toList(),
      imageHeight: image.height,
      imageWidth: image.width,
      imageMean: 0.0,
      imageStd: 255.0,
      rotation: 0,
      numResults: 1,
      threshold: 0.0,
    );

    if (results == null || results.isEmpty) return null;
    final top = results.first;
    final label = (top['label'] as String?)?.trim() ?? 'Unknown';
    final conf = (top['confidence'] as double?) ?? 0.0;
    final localizedLabel = DialectService.getLocalizedName(label);
    return TFLiteDetection(label: localizedLabel, confidence: conf);
  }

  Future<void> dispose() async {
    await Tflite.close();
  }
}
