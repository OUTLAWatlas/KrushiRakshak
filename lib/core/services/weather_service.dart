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

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

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
}
