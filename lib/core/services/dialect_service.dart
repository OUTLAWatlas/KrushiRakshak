class DialectService {
  static const Map<String, String> slangMap = {
    "Corn and Maize Blight": "Karpaa (करपा) - Fungal",
    "Corn and Maize Common Rust": "Taambera (तांबेरा)",
    "Soyabean Pest Attack": "Ali Humla (अळी हल्ला)",
    "Soyabean Rust": "Taambera (तांबेरा) - Critical",
    "Soyabean Mosaic": "Mosaic Virus (मोज़ेक)",
    "cotton bacterial blight": "Bacterial Karpa (करपा)",
    "cotton curl virus": "Kokda / Churda Murda (चुरडा मुरडा)",
    "cotton fussarium wilt": "Mar Rog (मर रोग)",
    "cotton red cotton leaf": "Lalya (लाल्या)",
  };

  static String getLocalizedName(String rawLabel) {
    final normalized = rawLabel.replaceAll(RegExp(r'\d'), '').trim();
    return slangMap[normalized] ?? rawLabel;
  }
}
