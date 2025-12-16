import 'package:flutter/material.dart';

class DosageCalculatorScreen extends StatefulWidget {
  const DosageCalculatorScreen({super.key, this.initialPest});

  final String? initialPest;

  @override
  State<DosageCalculatorScreen> createState() => _DosageCalculatorScreenState();
}

class _DosageCalculatorScreenState extends State<DosageCalculatorScreen> {
  final TextEditingController _tankSizeController = TextEditingController(text: '15');
  bool _isExportMode = false;
  late Map<String, dynamic> _selectedMedicine;

  final List<Map<String, dynamic>> _medicines = [
    {
      'name': 'Confidor',
      'dose_per_acre': 50.0,
      'is_banned_for_export': false,
    },
    {
      'name': 'Coragen',
      'dose_per_acre': 60.0,
      'is_banned_for_export': false,
    },
    {
      'name': 'Curacron',
      'dose_per_acre': 40.0,
      'is_banned_for_export': true,
    },
    {
      'name': 'Neem Oil',
      'dose_per_acre': 150.0,
      'is_banned_for_export': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedMedicine = _medicines.first;
  }

  @override
  void dispose() {
    _tankSizeController.dispose();
    super.dispose();
  }

  double _calculateCaps() {
    final tank = double.tryParse(_tankSizeController.text) ?? 0;
    final dosePerAcre = (_selectedMedicine['dose_per_acre'] as num).toDouble();
    final ml = (dosePerAcre / 200.0) * tank;
    return ml / 10.0; // 1 cap = 10 ml
  }

  @override
  Widget build(BuildContext context) {
    final filteredMedicines = _isExportMode
        ? _medicines.where((m) => m['is_banned_for_export'] == false).toList()
        : _medicines;

    if (!filteredMedicines.contains(_selectedMedicine)) {
      _selectedMedicine = filteredMedicines.first;
    }

    final caps = _calculateCaps();
    final isBanned = _isExportMode && (_selectedMedicine['is_banned_for_export'] as bool);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dosage Calculator'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.initialPest != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      'Pest: ${widget.initialPest}',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                TextField(
                  controller: _tankSizeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Tank Size (Liters)',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 12),
                SwitchListTile.adaptive(
                  title: const Text('Export Mode'),
                  activeColor: Colors.green,
                  value: _isExportMode,
                  onChanged: (val) {
                    setState(() {
                      _isExportMode = val;
                    });
                  },
                ),
                const SizedBox(height: 8),
                InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Select Medicine',
                    border: OutlineInputBorder(),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<Map<String, dynamic>>(
                      isExpanded: true,
                      value: _selectedMedicine,
                      items: filteredMedicines
                          .map(
                            (med) => DropdownMenuItem<Map<String, dynamic>>(
                              value: med,
                              child: Text(med['name'] as String),
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        if (val == null) return;
                        setState(() {
                          _selectedMedicine = val;
                        });
                      },
                    ),
                  ),
                ),
                if (isBanned)
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${_selectedMedicine['name']} is banned for export.',
                            style: TextStyle(color: Colors.red.shade800),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
                Center(
                  child: Column(
                    children: [
                      const Text(
                        'Required Dosage',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${caps.toStringAsFixed(1)} Caps',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
