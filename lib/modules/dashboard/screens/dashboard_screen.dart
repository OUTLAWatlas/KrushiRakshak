import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/services/database_service.dart';
import '../../../core/services/localization_service.dart';
import '../../../core/services/weather_service.dart';
import '../../calculator/screens/dosage_calculator_screen.dart';
import '../../scanner/screens/pest_scanner_screen.dart';
import '../widgets/timeline_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DatabaseService _db = DatabaseService();
  bool _loading = true;
  String _cropName = 'Cotton';
  String _variety = 'Hybrid';
  DateTime _sowingDate = DateTime.now().subtract(const Duration(days: 30));
  int _duration = 160;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      await _db.init();
      final data = _db.getUserProfile();
      if (data != null) {
        setState(() {
          _cropName = (data['crop'] as String?) ?? _cropName;
          _variety = (data['variety'] as String?) ?? _variety;
          _duration = (data['duration'] as int?) ?? _duration;
          final sowingStr = data['sowingDate'] as String?;
          final parsed = sowingStr != null ? DateTime.tryParse(sowingStr) : null;
          if (parsed != null) {
            _sowingDate = parsed;
          }
        });
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _openScanner() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const PestScannerScreen()),
    );
  }

  void _openDosageCalc() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const DosageCalculatorScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocalizationService>();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(loc.translate('app_title')),
        actions: [
          IconButton(
            icon: const Icon(Icons.translate),
            onPressed: () {
              loc.toggleLanguage();
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openScanner,
        icon: const Icon(Icons.qr_code_scanner),
        label: Text(loc.translate('scan_pest')),
        backgroundColor: Colors.green,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWeatherCard(),
                  const SizedBox(height: 16),
                  Text(
                    loc.translate('timeline'),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  CropTimelineCard(
                    cropName: _cropName,
                    sowingDate: _sowingDate,
                    totalDuration: _duration,
                    variety: _variety,
                    stageVegetativeLabel: loc.translate('stage_vegetative'),
                    stageFloweringLabel: loc.translate('stage_flowering'),
                    stageHarvestLabel: 'Harvest',
                  ),
                  const SizedBox(height: 16),
                  Text('Quick Actions', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: _quickActionCard(loc.translate('scan_pest'), Icons.bug_report, _openScanner)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _quickActionCard(
                          loc.translate('dosage_calc'),
                          Icons.water_drop,
                          _openDosageCalc,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildWeatherCard() {
    final loc = context.read<LocalizationService>();
    return FutureBuilder<Map<String, dynamic>>(
      future: WeatherService().getCurrentWeather(),
      builder: (context, snapshot) {
        final data = snapshot.data;
        final temp = data?['temp']?.toString() ?? '...';
        final humidity = data?['humidity']?.toString() ?? '...';
        final location = data?['location']?.toString() ?? loc.translate('weather');

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                location,
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                '$temp | $humidity',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _quickActionCard(String title, IconData icon, VoidCallback onTap) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          child: Column(
            children: [
              Icon(icon, color: Colors.green),
              const SizedBox(height: 8),
              Text(title),
            ],
          ),
        ),
      ),
    );
  }
}
