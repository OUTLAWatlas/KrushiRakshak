import 'dart:developer';

import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseService {
  DatabaseService._internal();

  static final DatabaseService _instance = DatabaseService._internal();

  factory DatabaseService() => _instance;

  Box<Map<String, dynamic>>? _userProfileBox;
  Box<dynamic>? _appSettingsBox;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) {
      return;
    }

    try {
      final appDirectory = await getApplicationDocumentsDirectory();
      await Hive.initFlutter(appDirectory.path);

      _userProfileBox =
          await Hive.openBox<Map<String, dynamic>>('user_profile');
      _appSettingsBox = await Hive.openBox<dynamic>('app_settings');

      _initialized = true;
    } catch (error, stackTrace) {
      log(
        'Failed to initialize Hive boxes',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<void> saveUserProfile(Map<String, dynamic> data) async {
    try {
      await _userProfileBox?.put('profile', data);
    } catch (error, stackTrace) {
      log(
        'Failed to save user profile',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Map<String, dynamic>? getUserProfile() {
    try {
      return _userProfileBox?.get('profile');
    } catch (error, stackTrace) {
      log(
        'Failed to get user profile',
        error: error,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  Future<void> clearAllData() async {
    // Helper for debugging and manual resets.
    try {
      await _userProfileBox?.clear();
      await _appSettingsBox?.clear();
    } catch (error, stackTrace) {
      log(
        'Failed to clear Hive data',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
}
