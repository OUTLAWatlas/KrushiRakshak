import 'package:flutter/material.dart';

import 'core/services/database_service.dart';
import 'modules/dashboard/screens/dashboard_screen.dart';
import 'modules/onboarding/screens/seed_scan_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final db = DatabaseService();
  await db.init();
  final profile = db.getUserProfile();
  final initialRoute = profile == null ? '/onboarding' : '/dashboard';

  runApp(KisaanRakshaApp(initialRoute: initialRoute));
}

class KisaanRakshaApp extends StatelessWidget {
  const KisaanRakshaApp({super.key, required this.initialRoute});

  final String initialRoute;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KisaanRaksha',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      initialRoute: initialRoute,
      routes: {
        '/onboarding': (_) => const SeedScanScreen(),
        '/dashboard': (_) => const DashboardScreen(),
      },
    );
  }
}
