import 'dart:async';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class WeatherService {
  // Get Real Location & Weather (temp/humidity simulated for now)
  Future<Map<String, dynamic>> getCurrentWeather() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        return _getMockData('Location Denied');
      }

      // Try to obtain a high-accuracy position by listening to the position stream
      final position = await _getBestPosition();

      String city = 'Unknown Field';
      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          city = placemarks.first.locality ?? 'Village';
        }
      } catch (_) {
        // ignore geocoding errors and fallback to default
      }

      return {
        'location': city,
        'temp': '31°C', // simulated for now
        'humidity': '65%',
        'condition': 'Sunny',
        'lat': position.latitude,
        'long': position.longitude,
      };
    } catch (_) {
      return _getMockData('GPS Error');
    }
  }

  Map<String, dynamic> _getMockData(String errorLocation) {
    return {
      'location': errorLocation,
      'temp': '--',
      'humidity': '--',
      'condition': 'Unknown',
      'lat': 19.0760,
      'long': 72.8777,
    };
  }

  Future<Position> _getBestPosition({int timeoutSeconds = 8}) async {
    try {
      // If there's a cached last known position, use it as a quick fallback
      final last = await Geolocator.getLastKnownPosition();
      final completer = Completer<Position>();

      // If last known is recent and reasonably accurate, return it quickly
      if (last != null && last.accuracy <= 50) {
        return last;
      }

      // Listen to the position stream requesting highest accuracy
      final stream = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          distanceFilter: 0,
          timeLimit: Duration(seconds: 1),
        ),
      );

      late final StreamSubscription<Position> sub;
      sub = stream.listen((pos) {
        // When we get a sufficiently accurate reading, complete
        if (!completer.isCompleted && pos.accuracy > 0 && pos.accuracy <= 30) {
          completer.complete(pos);
          sub.cancel();
        }
      }, onError: (err) {
        if (!completer.isCompleted) {
          completer.completeError(err);
        }
      });

      // Also set a timeout — if nothing accurate arrives, fallback to getCurrentPosition
      final pos = await completer.future.timeout(Duration(seconds: timeoutSeconds), onTimeout: () async {
        await sub.cancel();
        return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
      });

      return pos;
    } catch (_) {
      // final fallback to getCurrentPosition with best effort
      return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
    }
  }
}
