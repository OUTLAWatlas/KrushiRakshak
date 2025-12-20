import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/services/database_service.dart';
import 'core/services/hive_service.dart';
import 'core/services/ledger_service.dart';
import 'core/services/localization_service.dart';
import 'core/services/ocr_service.dart';
import 'core/services/tflite_service.dart';
import 'services/tts_service.dart';
import 'home_screen.dart';
import 'modules/dashboard/screens/dashboard_screen.dart';
import 'modules/onboarding/screens/seed_scan_screen.dart';
import 'modules/auth/register_screen.dart';
import 'modules/profile/screens/profile_screen.dart';
import 'core/theme/app_theme.dart';
import 'widgets/localization_picker.dart';

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
  final tts = TtsService();

  // Always start at dashboard to show home screen on app open
  const startRoute = '/dashboard';

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocalizationService()),
        ChangeNotifierProvider(create: (_) => LedgerService()),
        Provider<DatabaseService>.value(value: db),
        Provider<HiveService>.value(value: hive),
        Provider<TFLiteService>.value(value: tflite),
        Provider<OCRService>.value(value: ocr),
        Provider<TtsService>.value(value: tts),
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
    // Use a consumer so Theme/Locale react to language changes
    return Consumer<LocalizationService>(builder: (context, localeSrv, _) {
      final theme = AppTheme.build(localeSrv.locale);

      return MaterialApp(
        title: 'KisaanRaksha',
        key: ValueKey(localeSrv.locale),
        theme: theme,
        locale: Locale(localeSrv.locale),
        supportedLocales: const [Locale('en'), Locale('mr'), Locale('hi')],
        // basic Flutter localizations so built-in widgets also adapt
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        initialRoute: initialRoute,
        routes: {
          '/onboarding': (_) => const SeedScanScreen(),
          '/dashboard': (_) => const DashboardScreen(),
          '/profile': (_) => const ProfileScreen(),
          '/register': (_) => const RegisterScreen(),
          '/ai': (_) => const HomeScreen(),
        },
      );
    });
  }
}
