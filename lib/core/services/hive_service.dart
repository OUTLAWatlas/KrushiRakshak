import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static const _settingsBox = 'user_settings';
  static const _timelineBox = 'crop_timeline';

  Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_settingsBox);
    await Hive.openBox(_timelineBox);
  }

  // Settings box helpers
  String getLanguage() => Hive.box(_settingsBox).get('language', defaultValue: 'en');
  Future<void> setLanguage(String code) => Hive.box(_settingsBox).put('language', code);

  double getTankSize() => Hive.box(_settingsBox).get('tankSize', defaultValue: 15.0);
  Future<void> setTankSize(double liters) => Hive.box(_settingsBox).put('tankSize', liters);

  // Crop timeline helpers
  Map<String, dynamic>? getActiveCrop() => Hive.box(_timelineBox).get('activeCrop');
  Future<void> setActiveCrop(Map<String, dynamic> crop) => Hive.box(_timelineBox).put('activeCrop', crop);
  Future<void> clearActiveCrop() => Hive.box(_timelineBox).delete('activeCrop');
}
