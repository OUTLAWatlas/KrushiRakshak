class CropData {
  static const List<Map<String, Object>> maharashtraCrops = [
    {
      'id': 'cotton',
      'name': 'Cotton',
      'varieties': ['Hybrid Bt', 'Desi', 'MCU-5'],
      'stages': [
        {
          'stageName': 'Emergence',
          'startDay': 0,
          'endDay': 15,
          'riskPests': ['Seedling blight', 'Cutworms'],
        },
        {
          'stageName': 'Vegetative',
          'startDay': 16,
          'endDay': 60,
          'riskPests': ['Aphids', 'Jassids', 'Whiteflies'],
        },
        {
          'stageName': 'Square Formation',
          'startDay': 61,
          'endDay': 90,
          'riskPests': ['Bollworm eggs', 'Thrips'],
        },
        {
          'stageName': 'Flowering and Boll Set',
          'startDay': 91,
          'endDay': 130,
          'riskPests': ['Pink bollworm', 'American bollworm'],
        },
        {
          'stageName': 'Boll Maturation',
          'startDay': 131,
          'endDay': 160,
          'riskPests': ['Boll rot', 'Whiteflies'],
        },
      ],
    },
    {
      'id': 'soybean',
      'name': 'Soybean',
      'varieties': ['JS-335', 'MAUS-71', 'MAUS-158'],
      'stages': [
        {
          'stageName': 'Emergence',
          'startDay': 0,
          'endDay': 10,
          'riskPests': ['Damping off', 'Cutworms'],
        },
        {
          'stageName': 'Vegetative',
          'startDay': 11,
          'endDay': 40,
          'riskPests': ['Stem fly', 'Aphids'],
        },
        {
          'stageName': 'Flowering',
          'startDay': 41,
          'endDay': 60,
          'riskPests': ['Defoliators', 'Blister beetle'],
        },
        {
          'stageName': 'Pod Formation',
          'startDay': 61,
          'endDay': 85,
          'riskPests': ['Pod borers', 'Girdle beetle'],
        },
        {
          'stageName': 'Maturity',
          'startDay': 86,
          'endDay': 100,
          'riskPests': ['Pod shattering', 'Rust'],
        },
      ],
    },
    {
      'id': 'onion',
      'name': 'Onion',
      'varieties': ['Bhima Red', 'N-53', 'Agrifound Dark Red'],
      'stages': [
        {
          'stageName': 'Establishment',
          'startDay': 0,
          'endDay': 20,
          'riskPests': ['Damping off', 'Thrips'],
        },
        {
          'stageName': 'Vegetative',
          'startDay': 21,
          'endDay': 70,
          'riskPests': ['Thrips', 'Purple blotch'],
        },
        {
          'stageName': 'Bulb Initiation',
          'startDay': 71,
          'endDay': 95,
          'riskPests': ['Thrips', 'Downy mildew'],
        },
        {
          'stageName': 'Bulb Enlargement',
          'startDay': 96,
          'endDay': 115,
          'riskPests': ['Root rot', 'Thrips'],
        },
        {
          'stageName': 'Curing and Maturity',
          'startDay': 116,
          'endDay': 120,
          'riskPests': ['Neck rot', 'Storage mites'],
        },
      ],
    },
  ];

  static Map<String, Object>? getStageForDay(String cropId, int day) {
    if (day < 0) {
      return null;
    }

    Map<String, Object>? crop;
    for (final entry in maharashtraCrops) {
      if (entry['id'] == cropId) {
        crop = entry;
        break;
      }
    }

    if (crop == null) {
      return null;
    }

    final stages = crop['stages'] as List<Map<String, Object>>;
    for (final stage in stages) {
      final start = stage['startDay'] as int;
      final end = stage['endDay'] as int;
      if (day >= start && day <= end) {
        return stage;
      }
    }

    return null;
  }
}
