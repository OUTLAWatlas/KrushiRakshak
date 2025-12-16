import 'package:flutter/foundation.dart';

class ScanEntry {
  ScanEntry({
    required this.pestName,
    required this.confidence,
    required this.date,
    required this.userId,
  });

  final String pestName;
  final double confidence;
  final DateTime date;
  final String userId;
}

class LedgerService extends ChangeNotifier {
  final List<ScanEntry> _entries = [];

  List<ScanEntry> get entries => List.unmodifiable(_entries);

  void addEntry(ScanEntry entry) {
    _entries.insert(0, entry);
    notifyListeners();
  }
}
