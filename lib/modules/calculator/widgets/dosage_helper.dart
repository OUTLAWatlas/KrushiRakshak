import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/localization_service.dart';

class DosageCalculator {
  static Map<String, dynamic> calculateDosage({
    required double tankSizeLiters,
    required double dosePerAcreMl,
  }) {
    if (tankSizeLiters <= 0 || dosePerAcreMl <= 0) {
      return {'ok': false, 'reason': 'enter_valid_values'};
    }

    const double waterPerAcreLiters = 200;
    final double requiredMl = (dosePerAcreMl / waterPerAcreLiters) * tankSizeLiters;
    final double caps = requiredMl / 10; // 1 cap = 10 ml

    return {'ok': true, 'ml': requiredMl, 'caps': caps};
  }
}

class DosageCard extends StatefulWidget {
  const DosageCard({
    super.key,
    required this.pestName,
    required this.chemicalName,
    required this.dosePerAcreMl,
  });

  final String pestName;
  final String chemicalName;
  final double dosePerAcreMl;

  @override
  State<DosageCard> createState() => _DosageCardState();
}

class _DosageCardState extends State<DosageCard> {
  final TextEditingController _tankController = TextEditingController();
  String _resultText = '';

  @override
  void initState() {
    super.initState();
    _tankController.addListener(_recalculate);
  }

  void _recalculate() {
    final input = double.tryParse(_tankController.text);
    final loc = Provider.of<LocalizationService>(context, listen: false);
    if (input == null) {
      setState(() => _resultText = loc.translate('enter_valid_number'));
      return;
    }

    final result = DosageCalculator.calculateDosage(
      tankSizeLiters: input,
      dosePerAcreMl: widget.dosePerAcreMl,
    );

    if (result['ok'] == true) {
      final ml = (result['ml'] as double).toStringAsFixed(1);
      final caps = (result['caps'] as double).toStringAsFixed(1);
      final tmpl = loc.translate('add_ml_caps');
      final msg = tmpl.replaceAll('{ml}', ml).replaceAll('{caps}', caps);
      setState(() => _resultText = msg);
    } else {
      setState(() => _resultText = loc.translate(result['reason'] as String));
    }
  }

  @override
  void dispose() {
    _tankController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.chemicalName,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text('${Provider.of<LocalizationService>(context).translate('pest_label')}: ${widget.pestName}'),
            const SizedBox(height: 12),
            TextField(
              controller: _tankController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: Provider.of<LocalizationService>(context).translate('tank_size'),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _resultText.isEmpty
                  ? 'Enter tank size to calculate dosage'
                  : _resultText,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
