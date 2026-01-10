import 'package:flutter/material.dart';

class LocalizationService extends ChangeNotifier {
  // supports 'en' (default), 'mr' (Marathi), 'hi' (Hindi)
  String _locale = 'en';

  String get locale => _locale;

  void setLocale(String code) {
    if (_locale == code) return;
    _locale = code;
    notifyListeners();
  }

  void toggleToHindi() => setLocale(_locale == 'hi' ? 'en' : 'hi');

  String translate(String key) {
    final map = _localizedValues[key];
    if (map == null) return key;
    return map[_locale] ?? map['en'] ?? key;
  }

  // Minimal dictionary with English, Marathi, and Hindi entries
  final Map<String, Map<String, String>> _localizedValues = {
    'app_title': {
      'en': 'KrushiRakshak',
      'mr': 'क्रुषीरक्षक (KrushiRakshak)',
      'hi': 'क्रुषीरक्षक (KrushiRakshak)'
    },
    'scan_pest': {'en': 'Scan Pest', 'mr': 'कीड स्कॅन करा', 'hi': 'कीट स्कैन करें'},
    'dosage_calc': {'en': 'Dosage Calculator', 'mr': 'खत कॅल्क्युलेटर', 'hi': 'खुराक गणक'},
    'weather': {'en': 'Weather', 'mr': 'हवामान', 'hi': 'मौसम'},
    'timeline': {'en': 'Crop Status', 'mr': 'पिकाची स्थिती', 'hi': 'फसल की स्थिति'},
    'stage_flowering': {'en': 'Flowering', 'mr': 'फुलोरा', 'hi': 'फूलना'},
    'stage_vegetative': {'en': 'Vegetative', 'mr': 'शाकीय वाढ', 'hi': 'वनस्पति चरण'},
    'warning': {'en': 'Warning', 'mr': 'सावधान', 'hi': 'चेतावनी'},
    'humidity': {'en': 'Humidity', 'mr': 'आद्रता', 'hi': 'नमी'},
    'view_map': {'en': 'View Nearby Outbreaks', 'mr': 'जवळपासचा प्रादुर्भाव पहा', 'hi': 'पास की महामारी देखें'},
    'gps_wait': {'en': 'Waiting for GPS...', 'mr': 'GPS ची वाट पहात आहे...', 'hi': 'GPS का इंतजार...' },
    'location_denied': {'en': 'Location Denied', 'mr': 'स्थान परवानगी नाकारली', 'hi': 'स्थान अनुमति अस्वीकृत'},
    'quick_actions': {'en': 'Quick Actions', 'mr': 'जलद क्रिया', 'hi': 'त्वरित क्रियाएँ'},
    'previous_scans': {'en': 'Previous Scans', 'mr': 'मागील स्कॅन्स', 'hi': 'पिछले स्कैन'},
    'profile': {'en': 'Profile', 'mr': 'प्रोफाइल', 'hi': 'प्रोफ़ाइल'},
    'harvest_confirm_title': {'en': 'Harvest Crop?', 'mr': 'काढणी करायची?', 'hi': 'फसल कटाई?'},
    'harvest_confirm_content': {
      'en': 'This will end the current season and clear all data. Are you ready?',
      'mr': 'हे चालू हंगाम समाप्त करेल आणि सर्व डेटा साफ करेल. तयार आहात का?',
      'hi': 'यह वर्तमान मौसम समाप्त कर देगा और सभी डेटा साफ करेगा। क्या आप तैयार हैं?'
    },
    'cancel': {'en': 'Cancel', 'mr': 'रद्द करा', 'hi': 'रद्द करें'},
    'yes_harvest': {'en': 'Yes, Harvest', 'mr': 'होय, काढणी', 'hi': 'हाँ, कटाई करें'},
    'quick_scan': {'en': 'Quick Scan', 'mr': 'त्वरित स्कॅन', 'hi': 'त्वरित स्कैन'},
    'Seedling': {'en': 'Seedling', 'mr': 'अंकुर (Seedling)', 'hi': 'अंकुर'},
    'Vegetative': {'en': 'Vegetative', 'mr': 'शाकीय वाढ (Vegetative)', 'hi': 'वनस्पति'},
    'Flowering': {'en': 'Flowering', 'mr': 'फुलोरा (Flowering)', 'hi': 'फूलना'},
    'Harvest': {'en': 'Harvest', 'mr': 'काढणी (Harvest)', 'hi': 'कटाई'},
    // PEST NAMES (simple Hindi transliterations)
    'Pink Bollworm': {'en': 'Pink Bollworm', 'mr': 'शेंदरी बोंडअळी', 'hi': 'पिंक बॉलवर्म'},
    'Aphids': {'en': 'Aphids', 'mr': 'मावा (Aphids)', 'hi': 'एफिड'},
    'Thrips': {'en': 'Thrips', 'mr': 'फुलकिडे (Thrips)', 'hi': 'थ्रिप्स'},
    'Stem Fly': {'en': 'Stem Fly', 'mr': 'खोडमाशी', 'hi': 'स्टेम फ्लाई'},
    'Leaf Miner': {'en': 'Leaf Miner', 'mr': 'पाने पोखरणारी अळी', 'hi': 'लीफ माइनर'},
    'Rust': {'en': 'Rust', 'mr': 'तांबेरा', 'hi': 'रस्ट'},
    'Fall Armyworm': {'en': 'Fall Armyworm', 'mr': 'लष्करी अळी', 'hi': 'फॉल आर्मीवर्म'},
    'Whitefly': {'en': 'Whitefly', 'mr': 'पांढरी माशी', 'hi': 'व्हाइटफ्लाय'},
    // Pest scanner UI
    'pest_scanner_title': {'en': 'Pest Scanner', 'mr': 'कीड स्कॅनर', 'hi': 'कीट स्कैनर'},
    'simulate_detection': {'en': 'Simulate Pest Detection', 'mr': 'कीड शोधण्याचे अनुकरण करा', 'hi': 'कीट पहचान का अनुकरण करें'},
    'confidence': {'en': 'Confidence', 'mr': 'विश्वास', 'hi': 'विश्वास'},
    'solution': {'en': 'Solution', 'mr': 'उपाय', 'hi': 'समाधान'},
    'save_to_ledger': {'en': 'Save to Ledger', 'mr': 'लजर मध्ये जतन करा', 'hi': 'लेजर में सहेजें'},
    'saved_to_ledger': {'en': 'Saved to ledger', 'mr': 'लजर मध्ये जतन झाले', 'hi': 'लेजर में सहेजा गया'},
    'unknown': {'en': 'Unknown', 'mr': 'अज्ञात', 'hi': 'अज्ञात'},
    // Seed scan / onboarding
    'seed_scan_title': {'en': 'Seed Scan', 'mr': 'बियाणे स्कॅन', 'hi': 'बीज स्कैन'},
    'confirm_crop_details': {'en': 'Confirm Crop Details', 'mr': 'पिक तपशील पुष्टि करा', 'hi': 'फसल विवरण की पुष्टि करें'},
    'detected': {'en': 'Detected', 'mr': 'सापडले', 'hi': 'पहचाना गया'},
    'seed_variety_hybrid': {'en': 'Seed Variety: Hybrid (Auto-Detected)', 'mr': 'बियाण्याची प्रकार: हायब्रिड (स्वतः ओळखले)', 'hi': 'बीज किस्म: हाइब्रिड (स्वचालित रूप से पहचाना)'},
    'sowing_date': {'en': 'Sowing Date (Lagwad):', 'mr': 'पेरणी तारीख (लगवड):', 'hi': 'बुआई की तारीख (लागवड):'},
    'retake_photo': {'en': 'Retake Photo', 'mr': 'परत फोटो घ्या', 'hi': 'फिर से फोटो लें'},
    'confirm_and_start': {'en': 'Confirm & Start', 'mr': 'पुष्टी करा आणि सुरू करा', 'hi': 'पुष्टि करें और शुरू करें'},
    'processing': {'en': 'Processing...', 'mr': 'प्रक्रिया चालू आहे...', 'hi': 'प्रसंस्करण हो रहा है...'},
    'capture_seed_packet': {'en': 'Capture Seed Packet', 'mr': 'बियाणे पॅकेट घ्या', 'hi': 'बीज पैकेट कैप्चर करें'},
    'skip_onboarding': {'en': 'Skip onboarding', 'mr': 'ऑनबोर्डिंग वगळा', 'hi': 'ऑनबोर्डिंग छोड़ें'},
    'we_guessed': {'en': '💡 We guessed this date based on the {crop} season. Tap to change if incorrect.', 'mr': '💡 आम्ही हा दिनांक {crop} हंगामावरून गृहीत धरला आहे. चुका असल्यास टॅप करा.', 'hi': '💡 हमने यह तिथि {crop} मौसम के आधार पर अनुमान लगाई है। यदि गलत हो तो टैप करें.'},
    // Profile
    'farm_ledger': {'en': 'Farm Ledger', 'mr': 'फार्म लेजर', 'hi': 'फार्म लेजर'},
    'logout': {'en': 'Logout', 'mr': 'बाहेर पडा', 'hi': 'लॉगआउट'},
    'farm_size': {'en': 'Farm Size', 'mr': 'शेताचे क्षेत्र', 'hi': 'खेत का आकार'},
    // Dosage calculator
    'tank_size': {'en': 'Tank Size (Liters)', 'mr': 'टँक आकार (लिटर)', 'hi': 'टैंक आकार (लीटर)'},
    'export_mode': {'en': 'Export Mode', 'mr': 'निर्यात मोड', 'hi': 'निर्यात मोड'},
    'select_medicine': {'en': 'Select Medicine', 'mr': 'औषध निवडा', 'hi': 'दवाई चुनें'},
    'required_dosage': {'en': 'Required Dosage', 'mr': 'आवश्यक मात्रा', 'hi': 'आवश्यक खुराक'},
    'caps': {'en': 'Caps', 'mr': 'कॅप्स', 'hi': 'कैप्स'},
    'banned_for_export': {'en': '{name} is banned for export.', 'mr': '{name} निर्यातीसाठी बंद आहे.', 'hi': '{name} निर्यात के लिए प्रतिबंधित है.'},
    'pest_label': {'en': 'Pest', 'mr': 'कीड', 'hi': 'कीट'},
    'high_humidity_warning': {
      'en': 'High Humidity ({humidity}) detected. Risk of {pest} is High.',
      'mr': 'उच्च आर्द्रता ({humidity}) आढळली. {pest} चा धोका जास्त आहे.',
      'hi': 'उच्च नमी ({humidity}) का पता चला। {pest} का खतरा अधिक है.'
    },
    // Map screen
    'pest_radar': {'en': 'Pest Radar', 'mr': 'कीटक राडार', 'hi': 'कीट रेडार'},
    'showing_risks_for': {'en': 'Showing risks for {crop}', 'mr': '{crop} साठी जोखीम दाखवत आहे', 'hi': '{crop} के लिए खतरे दिखा रहा है'},
    'you': {'en': 'You', 'mr': 'तुम', 'hi': 'आप'},
    // TFLite / telemetry messages
    'tflite_missing': {'en': 'TFLite model missing — some features disabled.', 'mr': 'TFLite मॉडेल गायब - काही वैशिष्ट्ये अक्षम.', 'hi': 'TFLite मॉडल गायब — कुछ सुविधाएँ अक्षम हैं.'},
    // Register screen
    'register': {'en': 'Register', 'mr': 'नोंदणी', 'hi': 'रजिस्टर'},
    'name': {'en': 'Name', 'mr': 'नाव', 'hi': 'नाम'},
    'phone_number': {'en': 'Phone Number', 'mr': 'फोन नंबर', 'hi': 'फोन नंबर'},
    'otp': {'en': 'OTP', 'mr': 'ओटीपी', 'hi': 'ओटीपी'},
    'send_otp': {'en': 'Send OTP', 'mr': 'ओटीपी पाठवा', 'hi': 'ओटीपी भेजें'},
    // Dosage helper messages
    'enter_valid_values': {'en': 'Enter valid values', 'mr': 'वैध मूल्य टाका', 'hi': 'मान्य मान दर्ज करें'},
    'enter_valid_number': {'en': 'Enter a valid number', 'mr': 'वैध संख्या टाका', 'hi': 'मान्य संख्या दर्ज करें'},
    'enter_tank_size_to_calculate': {'en': 'Enter tank size to calculate dosage', 'mr': 'खुराक गणना करण्यासाठी टँक आकार प्रविष्ट करा', 'hi': 'खुराक गणना करने के लिए टैंक आकार दर्ज करें'},
    'add_ml_caps': {'en': 'Add {ml} ml (approx {caps} caps)', 'mr': '{ml} मि.ली. जोडा (सुमारे {caps} कॅप्स)', 'hi': '{ml} मि.ली. जोड़ें (लगभग {caps} कैप्स)'},
  };
}
