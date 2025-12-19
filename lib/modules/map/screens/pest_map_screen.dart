import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../../core/services/localization_service.dart';

class PestOutbreak {
  PestOutbreak(this.pestName, this.cropType, this.location, this.severityColor);

  final String pestName;
  final String cropType;
  final LatLng location;
  final Color severityColor;
}

class PestMapScreen extends StatefulWidget {
  const PestMapScreen({
    super.key,
    required this.userLat,
    required this.userLong,
    required this.userCrop,
  });

  final double userLat;
  final double userLong;
  final String userCrop;

  @override
  State<PestMapScreen> createState() => _PestMapScreenState();
}

class _PestMapScreenState extends State<PestMapScreen> {
  List<PestOutbreak> _visibleOutbreaks = [];

  @override
  void initState() {
    super.initState();
    _generateMockOutbreaks();
  }

  void _generateMockOutbreaks() {
    final lat = widget.userLat;
    final long = widget.userLong;
    final r = Random();

    final allOutbreaks = [
      PestOutbreak('Pink Bollworm', 'Cotton', LatLng(lat + 0.005, long + 0.005), Colors.red),
      PestOutbreak('Aphids', 'Cotton', LatLng(lat - 0.004, long - 0.002), Colors.orange),
      PestOutbreak('Thrips', 'Cotton', LatLng(lat + 0.003, long - 0.006), Colors.orange),
      PestOutbreak('Stem Fly', 'Soybean', LatLng(lat + 0.006, long + 0.002), Colors.red),
      PestOutbreak('Leaf Miner', 'Soybean', LatLng(lat - 0.005, long - 0.005), Colors.orange),
      PestOutbreak('Rust', 'Wheat', LatLng(lat + 0.002, long + 0.008), Colors.brown),
    ];

    setState(() {
      _visibleOutbreaks = allOutbreaks
          .where((o) => widget.userCrop.contains(o.cropType))
          .toList();
      if (_visibleOutbreaks.isEmpty) {
        // Fallback: show at least one nearby marker even if crop mismatch
        _visibleOutbreaks = [
          PestOutbreak('General Pest', widget.userCrop, LatLng(lat + 0.002, long + 0.002), Colors.orange),
        ];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LocalizationService>(context);
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(lang.translate('pest_radar'), style: const TextStyle(fontSize: 18)),
            Text(
              lang.translate('showing_risks_for').replaceAll('{crop}', widget.userCrop),
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        backgroundColor: Colors.red[800],
        foregroundColor: Colors.white,
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(widget.userLat, widget.userLong),
          initialZoom: 14.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.kisaan_raksha',
          ),
          CircleLayer(
            circles: _visibleOutbreaks
                .map(
                  (outbreak) => CircleMarker(
                    point: outbreak.location,
                    color: outbreak.severityColor.withOpacity(0.2),
                    borderStrokeWidth: 2,
                    borderColor: outbreak.severityColor,
                    radius: 300,
                    useRadiusInMeter: true,
                  ),
                )
                .toList(),
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(widget.userLat, widget.userLong),
                width: 80,
                height: 80,
                child: Column(
                  children: [
                    const Icon(Icons.person_pin_circle, color: Colors.blue, size: 40),
                    Text(lang.translate('you'), style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              ..._visibleOutbreaks.map(
                (outbreak) => Marker(
                  point: outbreak.location,
                  width: 120,
                  height: 90,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: const [
                            BoxShadow(blurRadius: 4, color: Colors.black26),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.bug_report, color: outbreak.severityColor, size: 16),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                lang.translate(outbreak.pestName),
                                style: TextStyle(
                                  color: outbreak.severityColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_drop_down, color: outbreak.severityColor, size: 30),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
