class CropCalculator {
  static Map<String, dynamic> timelineStage(DateTime sowingDate) {
    final days = DateTime.now().difference(sowingDate).inDays;
    String stage;
    if (days < 15) {
      stage = 'Seedling';
    } else if (days < 45) {
      stage = 'Vegetative';
    } else if (days < 90) {
      stage = 'Flowering';
    } else {
      stage = 'Harvest';
    }
    return {'daysElapsed': days, 'stage': stage};
  }

  static int capsNeeded({required double tankSizeLiters, required double dosagePerLiterMl}) {
    final totalMl = tankSizeLiters * dosagePerLiterMl;
    return (totalMl / 10).ceil();
  }
}
