import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/services/database_service.dart';
import '../../../core/services/tflite_service.dart';
import '../../../core/services/ledger_service.dart';
import '../../../core/services/localization_service.dart';
import '../../../core/services/weather_service.dart';
import 'package:lottie/lottie.dart';
import '../../calculator/screens/dosage_calculator_screen.dart';
import '../../map/screens/pest_map_screen.dart';
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

  Future<void> _confirmHarvest(BuildContext context) async {
    final loc = context.read<LocalizationService>();
    final shouldReset = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(loc.translate('harvest_confirm_title')),
        content: Text(loc.translate('harvest_confirm_content')),
        actions: [
          TextButton(
            child: Text(loc.translate('cancel')),
            onPressed: () => Navigator.pop(ctx, false),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(loc.translate('yes_harvest'), style: const TextStyle(color: Colors.white)),
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ],
      ),
    );

    if (shouldReset == true) {
      await _db.clearAllData();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/onboarding', (route) => false);
      }
    }
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
      // Notify about missing TFLite model after build so user sees message.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final tflite = context.read<TFLiteService>();
        final loc = context.read<LocalizationService>();
        if (!tflite.modelAvailable && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(loc.translate('tflite_missing')),
              duration: const Duration(seconds: 4),
            ),
          );
        }
      });
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
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
          child: Text(loc.translate('app_title'), key: ValueKey(loc.locale)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: loc.translate('profile'),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
          IconButton(
            icon: const Icon(Icons.translate),
            onPressed: () => loc.toggleToHindi(),
            tooltip: 'Toggle Language',
          ),
          IconButton(
            icon: const Icon(Icons.restart_alt),
            tooltip: 'Harvest & Reset',
            onPressed: () => _confirmHarvest(context),
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
                  _buildWeatherCard(_cropName),
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
                    stageHarvestLabel: loc.translate('Harvest'),
                  ),
                  const SizedBox(height: 16),
                  Text(loc.translate('quick_actions'), style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: _AnimatedActionCard(title: loc.translate('scan_pest'), icon: Icons.bug_report, onTap: _openScanner)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _AnimatedActionCard(
                          title: loc.translate('dosage_calc'),
                          icon: Icons.water_drop,
                          onTap: _openDosageCalc,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildLedgerList(),
                ],
              ),
            ),
    );
  }

  Widget _buildWeatherCard(String cropName) {
    final loc = context.watch<LocalizationService>();

    return FutureBuilder<Map<String, dynamic>>(
      future: WeatherService().getCurrentWeather(),
      builder: (context, snapshot) {
        final data = snapshot.data;
        final location = data?['location']?.toString() ?? loc.translate('weather');
        final temp = data?['temp']?.toString() ?? '--';
        final humidityVal = data?['humidity']?.toString() ?? '--';
        final condition = data?['condition']?.toString() ?? '';

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green[800]!, Colors.green[600]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.location_on, color: Colors.white70, size: 16),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                location,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              temp,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                condition,
                                style: const TextStyle(color: Colors.white70, fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Lottie animation column
                  SizedBox(
                    width: 100,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Lottie.network(
                            'https://assets6.lottiefiles.com/packages/lf20_jtbfg2nb.json',
                            height: 72,
                            width: 72,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              const Icon(Icons.water_drop, color: Colors.lightBlueAccent),
                              const SizedBox(height: 4),
                              Text(
                                humidityVal,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                loc.translate('humidity'),
                                style: const TextStyle(color: Colors.white70, fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              const Divider(color: Colors.white24),
              const SizedBox(height: 5),
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () {
                    if (data != null && data['lat'] != null && data['long'] != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PestMapScreen(
                            userLat: (data['lat'] as num).toDouble(),
                            userLong: (data['long'] as num).toDouble(),
                            userCrop: cropName.isNotEmpty ? cropName : 'Cotton',
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(loc.translate('gps_wait'))),
                      );
                    }
                  },
                  icon: const Icon(Icons.map, color: Colors.white),
                  label: Text(
                    loc.translate('view_map'),
                    style: const TextStyle(color: Colors.white),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.1),
                  ),
                ),
              )
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

  Widget _buildLedgerList() {
    final ledger = context.watch<LedgerService>();
    if (ledger.entries.isEmpty) {
      return const SizedBox();
    }

    final loc = context.watch<LocalizationService>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(loc.translate('previous_scans'), style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (_, index) {
            final entry = ledger.entries[index];
            return ListTile(
              leading: const CircleAvatar(child: Icon(Icons.bug_report)),
              title: Text(loc.translate(entry.pestName)),
              subtitle: Text(entry.date.toLocal().toString().split('.').first),
              trailing: Text('${(entry.confidence * 100).toStringAsFixed(0)}%'),
            );
          },
          separatorBuilder: (_, __) => const Divider(),
          itemCount: ledger.entries.length,
        ),
      ],
    );
  }

}

class _AnimatedActionCard extends StatefulWidget {
  const _AnimatedActionCard({required this.title, required this.icon, required this.onTap});

  final String title;
  final IconData icon;
  final VoidCallback onTap;

  @override
  State<_AnimatedActionCard> createState() => _AnimatedActionCardState();
}

class _AnimatedActionCardState extends State<_AnimatedActionCard> with SingleTickerProviderStateMixin {
  double _scale = 1.0;

  void _onTapDown(TapDownDetails details) => setState(() => _scale = 0.96);
  void _onTapUp(TapUpDetails details) => setState(() => _scale = 1.0);
  void _onTapCancel() => setState(() => _scale = 1.0);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: (d) {
        _onTapUp(d);
        widget.onTap();
      },
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
            child: Column(
              children: [
                Icon(widget.icon, color: Theme.of(context).colorScheme.primary, size: 28),
                const SizedBox(height: 10),
                Text(widget.title, textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
