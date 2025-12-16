import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/services/database_service.dart';
import 'core/services/hive_service.dart';
import 'core/services/ledger_service.dart';
import 'core/services/localization_service.dart';
import 'core/services/ocr_service.dart';
import 'core/services/tflite_service.dart';
import 'modules/dashboard/screens/dashboard_screen.dart';
import 'modules/onboarding/screens/seed_scan_screen.dart';
import 'modules/auth/register_screen.dart';
import 'modules/profile/screens/profile_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final db = DatabaseService();
  await db.init();
  // Initialize shared services
  final hive = HiveService();
  await hive.init();
  final tflite = TFLiteService();
  await tflite.loadModel();
  final ocr = OCRService();

  final userProfile = db.getUserProfile();
  final startRoute = userProfile != null ? '/dashboard' : '/onboarding';

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocalizationService()),
        ChangeNotifierProvider(create: (_) => LedgerService()),
        Provider<DatabaseService>.value(value: db),
        Provider<HiveService>.value(value: hive),
        Provider<TFLiteService>.value(value: tflite),
        Provider<OCRService>.value(value: ocr),
      ],
      child: KisaanRakshaApp(initialRoute: startRoute),
    ),
  );
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
        '/profile': (_) => const ProfileScreen(),
        '/register': (_) => const RegisterScreen(),
      },
    );
  }
}
