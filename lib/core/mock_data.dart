import 'package:flutter/material.dart';

class MockData {
  static const Map<String, String> user = {
    'name': 'Ramesh Kumar',
    'phone': '+91 98765 43210',
    'location': 'Pune, MH',
    'farmSize': '5 Acres',
  };

  // History intentionally cleared for demo privacy.
  static final List<Map<String, String>> history = [];

  static Color severityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return Colors.red.shade900;
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.blueGrey;
    }
  }
}
