import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class WeatherService {
  static const _apiKey = 'YOUR_OPENWEATHERMAP_KEY';

  Future<Map<String, dynamic>> getCurrentWeather() async {
    try {
      final hasPermission = await _ensureLocationPermission();
      if (!hasPermission) throw Exception('Location permission denied');

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?lat=${position.latitude}&lon=${position.longitude}&appid=$_apiKey&units=metric',
      );

      final resp = await http.get(url).timeout(const Duration(seconds: 8));
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        final main = data['main'] as Map<String, dynamic>?;
        final name = data['name']?.toString() ?? 'Unknown';
        final temp = main?['temp']?.toString();
        final humidity = main?['humidity']?.toString();
        return {
          'temp': temp != null ? '${temp}°C' : 'N/A',
          'humidity': humidity != null ? '$humidity%' : 'N/A',
          'location': name,
        };
      }

      throw Exception('Weather API error ${resp.statusCode}');
    } catch (_) {
      return {
        'temp': '32°C',
        'humidity': 'High',
        'location': 'Yavatmal (Offline Mode)',
      };
    }
  }

  Future<bool> _ensureLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }
}
