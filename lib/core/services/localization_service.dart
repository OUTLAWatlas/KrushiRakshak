import 'package:flutter/material.dart';

class LocalizationService extends ChangeNotifier {
  bool _isMarathi = false;

  bool get isMarathi => _isMarathi;

  void toggleLanguage() {
    _isMarathi = !_isMarathi;
    notifyListeners();
  }

  String translate(String key) {
    if (_localizedValues.containsKey(key)) {
      return _isMarathi ? _localizedValues[key]!['mr']! : _localizedValues[key]!['en']!;
    }
    return key; // Fallback to the key itself if not found
  }

  // THE EXPANDED DICTIONARY
  final Map<String, Map<String, String>> _localizedValues = {
    'app_title': {'en': 'PikVedh', 'mr': 'पिकवेध (PikVedh)'},
    'scan_pest': {'en': 'Scan Pest', 'mr': 'कीड स्कॅन करा'},
    'dosage_calc': {'en': 'Dosage Calculator', 'mr': 'खत कॅल्क्युलेटर'},
    'weather': {'en': 'Weather', 'mr': 'हवामान'},
    'timeline': {'en': 'Crop Status', 'mr': 'पिकाची स्थिती'},
    'stage_flowering': {'en': 'Flowering', 'mr': 'फुलोरा'},
    'stage_vegetative': {'en': 'Vegetative', 'mr': 'शाकीय वाढ'},
    'warning': {'en': 'Warning', 'mr': 'सावधान'},

    // NEW KEYS FOR WEATHER PANEL
    'humidity': {'en': 'Humidity', 'mr': 'आद्रता'},
    'view_map': {'en': 'View Nearby Outbreaks', 'mr': 'जवळपासचा प्रादुर्भाव पहा'},
    'gps_wait': {'en': 'Waiting for GPS...', 'mr': 'GPS ची वाट पहात आहे...'},
    'location_denied': {'en': 'Location Denied', 'mr': 'स्थान परवानगी नाकारली'},

    // Additional stages used elsewhere
    'Seedling': {'en': 'Seedling', 'mr': 'अंकुर (Seedling)'},
    'Vegetative': {'en': 'Vegetative', 'mr': 'शाकीय वाढ (Vegetative)'},
    'Flowering': {'en': 'Flowering', 'mr': 'फुलोरा (Flowering)'},
    'Harvest': {'en': 'Harvest', 'mr': 'काढणी (Harvest)'},

    // PEST NAMES
    'Pink Bollworm': {'en': 'Pink Bollworm', 'mr': 'शेंदरी बोंडअळी'},
    'Aphids': {'en': 'Aphids', 'mr': 'मावा (Aphids)'},
    'Thrips': {'en': 'Thrips', 'mr': 'फुलकिडे (Thrips)'},
    'Stem Fly': {'en': 'Stem Fly', 'mr': 'खोडमाशी'},
    'Leaf Miner': {'en': 'Leaf Miner', 'mr': 'पाने पोखरणारी अळी'},
    'Rust': {'en': 'Rust', 'mr': 'तांबेरा'},
    'Fall Armyworm': {'en': 'Fall Armyworm', 'mr': 'लष्करी अळी'},
    'Whitefly': {'en': 'Whitefly', 'mr': 'पांढरी माशी'},
  };
}
