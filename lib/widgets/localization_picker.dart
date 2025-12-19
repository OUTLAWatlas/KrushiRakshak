import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/services/localization_service.dart';

class LocalizationPicker extends StatelessWidget {
  const LocalizationPicker({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocalizationService>();
    return DropdownButton<String>(
      value: loc.locale,
      items: const [
        DropdownMenuItem(value: 'en', child: Text('English')),
        DropdownMenuItem(value: 'mr', child: Text('मराठी')),
        DropdownMenuItem(value: 'hi', child: Text('हिन्दी')),
      ],
      onChanged: (v) {
        if (v == null) return;
        loc.setLocale(v);
      },
    );
  }
}
