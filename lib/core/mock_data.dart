import 'package:flutter/material.dart';

class MockData {
  static const Map<String, String> user = {
    'name': 'Ramesh Kumar',
    'phone': '+91 98765 43210',
    'location': 'Nashik, MH',
    'farmSize': '5 Acres',
  };

  static final List<Map<String, String>> history = [
    {
      'date': 'Today',
      'pest': 'Fall Armyworm',
      'severity': 'High',
      'status': 'Action Needed',
    },
    {
      'date': 'Yesterday',
      'pest': 'Aphids',
      'severity': 'Low',
      'status': 'Resolved',
    },
    {
      'date': 'Oct 24',
      'pest': 'Pink Bollworm',
      'severity': 'Critical',
      'status': 'Resolved',
    },
    {
      'date': 'Oct 10',
      'pest': 'Thrips',
      'severity': 'Medium',
      'status': 'Monitoring',
    },
    {
      'date': 'Sep 28',
      'pest': 'Stem Fly',
      'severity': 'Low',
      'status': 'Resolved',
    },
  ];

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
