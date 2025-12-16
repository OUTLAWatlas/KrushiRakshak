import 'package:flutter/foundation.dart';

class LocalizationService extends ChangeNotifier {
  bool isMarathi = false;

  final Map<String, Map<String, String>> _dictionary = {
    'app_title': {
      'en': 'PikVedh',
      'mr': 'पिकवेध (PikVedh)',
    },
    'scan_pest': {
      'en': 'Scan Pest',
      'mr': 'कीड स्कॅन करा',
    },
    'dosage_calc': {
      'en': 'Dosage Calculator',
      'mr': 'खत कॅल्क्युलेटर',
    },
    'weather': {
      'en': 'Weather',
      'mr': 'हवामान',
    },
    'timeline': {
      'en': 'Crop Timeline',
      'mr': 'पिकाची वेळ',
    },
    'stage_flowering': {
      'en': 'Flowering',
      'mr': 'फुलोरा',
    },
    'stage_vegetative': {
      'en': 'Vegetative',
      'mr': 'शाकीय वाढ',
    },
    'warning': {
      'en': 'Warning',
      'mr': 'सावधान',
    },
  };

  void toggleLanguage() {
    isMarathi = !isMarathi;
    notifyListeners();
  }

  String translate(String key) {
    final lang = isMarathi ? 'mr' : 'en';
    return _dictionary[key]?[lang] ?? key;
  }
}
