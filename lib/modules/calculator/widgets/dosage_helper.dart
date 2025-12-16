import 'package:flutter/material.dart';

class DosageCalculator {
  static String calculateDosage({
    required double tankSizeLiters,
    required double dosePerAcreMl,
  }) {
    if (tankSizeLiters <= 0 || dosePerAcreMl <= 0) {
      return 'Enter valid values';
    }

    const double waterPerAcreLiters = 200;
    final double requiredMl = (dosePerAcreMl / waterPerAcreLiters) * tankSizeLiters;
    final double caps = requiredMl / 10; // 1 cap = 10 ml

    return 'Add ${requiredMl.toStringAsFixed(1)} ml (approx ${caps.toStringAsFixed(1)} caps)';
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
    if (input == null) {
      setState(() => _resultText = 'Enter a valid number');
      return;
    }
    final result = DosageCalculator.calculateDosage(
      tankSizeLiters: input,
      dosePerAcreMl: widget.dosePerAcreMl,
    );
    setState(() => _resultText = result);
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
            Text('Target pest: ${widget.pestName}'),
            const SizedBox(height: 12),
            TextField(
              controller: _tankController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Tank size (Liters)',
                border: OutlineInputBorder(),
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
