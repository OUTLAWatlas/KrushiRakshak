import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class Prediction {
  Prediction({required this.label, required this.score});
  final String label;
  final double score;
}

class TFLiteService {
  Interpreter? _interpreter;
  List<String> _labels = const [];

  Future<void> loadModel({
    String modelPath = 'assets/models/pest_model.tflite',
    String labelsPath = 'assets/models/pest_labels.txt',
  }) async {
    _interpreter = await Interpreter.fromAsset(modelPath);
    _labels = await _loadLabels(labelsPath);
  }

  Future<List<Prediction>> analyzeImage(File file) async {
    if (_interpreter == null) {
      throw StateError('Interpreter not loaded. Call loadModel first.');
    }
    final bytes = await file.readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return [];

    final input = _preprocess(decoded, _interpreter!);
    final outputTensor = _interpreter!.getOutputTensor(0);
    final numLabels = outputTensor.shape.last;
    final output = List.generate(1, (_) => List.filled(numLabels, 0.0));

    _interpreter!.run(input, output);
    final scores = output.first;
    final results = <Prediction>[];
    for (var i = 0; i < scores.length; i++) {
      results.add(Prediction(
        label: i < _labels.length ? _labels[i] : 'Label $i',
        score: scores[i],
      ));
    }
    results.sort((a, b) => b.score.compareTo(a.score));
    return results;
  }

  List<List<List<List<double>>>> _preprocess(img.Image image, Interpreter interpreter) {
    final inputTensor = interpreter.getInputTensor(0);
    final shape = inputTensor.shape; // [1, h, w, c]
    final h = shape[1];
    final w = shape[2];
    final resized = img.copyResize(image, width: w, height: h);

    return [
      List.generate(
        h,
        (y) => List.generate(
          w,
          (x) {
            final pixel = resized.getPixel(x, y);
            return [
              img.getRed(pixel) / 255.0,
              img.getGreen(pixel) / 255.0,
              img.getBlue(pixel) / 255.0,
            ];
          },
        ),
      ),
    ];
  }

  Future<List<String>> _loadLabels(String assetPath) async {
    final raw = await rootBundle.loadString(assetPath);
    return raw.split('\n').where((line) => line.trim().isNotEmpty).toList();
  }

  void dispose() {
    _interpreter?.close();
  }
}
