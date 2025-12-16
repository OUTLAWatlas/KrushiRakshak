class CropData {
  static const List<Map<String, dynamic>> allCrops = [
    {
      'id': 'cotton',
      'name': 'Cotton (Kapus)',
      'duration': 160,
      'sowingWindowStart': 6, // June
      'sowingWindowEnd': 7,   // July
      'stages': [
        {'name': 'Seedling', 'days': 20},
        {'name': 'Vegetative', 'days': 50},
        {'name': 'Flowering', 'days': 100},
        {'name': 'Boll Formation', 'days': 140},
        {'name': 'Harvest', 'days': 160},
      ]
    },
    {
      'id': 'soybean',
      'name': 'Soybean',
      'duration': 100,
      'sowingWindowStart': 6, // June
      'sowingWindowEnd': 7,   // July
      'stages': [
        {'name': 'Seedling', 'days': 15},
        {'name': 'Vegetative', 'days': 35},
        {'name': 'Flowering', 'days': 65},
        {'name': 'Pod Formation', 'days': 85},
        {'name': 'Harvest', 'days': 100},
      ]
    },
    {
      'id': 'wheat',
      'name': 'Wheat (Gahu)',
      'duration': 120,
      'sowingWindowStart': 10, // October
      'sowingWindowEnd': 11,   // November
      'stages': [
        {'name': 'Crown Root', 'days': 25},
        {'name': 'Tillering', 'days': 45},
        {'name': 'Jointing', 'days': 65},
        {'name': 'Flowering', 'days': 85},
        {'name': 'Harvest', 'days': 120},
      ]
    },
  ];

  // Helper: "Smart Guess" Logic
  static DateTime estimateSowingDate(String cropId) {
    final crop = allCrops.firstWhere((c) => c['id'] == cropId, orElse: () => allCrops[0]);
    final now = DateTime.now();
    final startMonth = crop['sowingWindowStart'];
    final endMonth = crop['sowingWindowEnd'];

    // 1. If today is INSIDE the sowing window, assume 'Today' (Just planted)
    if (now.month >= startMonth && now.month <= endMonth) {
      return now;
    }

    // 2. If today is AFTER the window (e.g., It's August, Cotton was sown in June)
    // We guess the "Middle" of the sowing window from THIS year.
    // Example: If now is Aug 2025, and window is June-July, we guess June 15, 2025.
    if (now.month > endMonth) {
      return DateTime(now.year, startMonth, 15); // Guess Mid-June
    }

    // 3. If today is BEFORE the window (e.g., It's Jan, Cotton starts in June)
    // It implies this is a "Late Harvest" from LAST year's crop.
    if (now.month < startMonth) {
      return DateTime(now.year - 1, startMonth, 15); // Guess Mid-June of LAST year
    }

    return now; // Fallback
  }
}
