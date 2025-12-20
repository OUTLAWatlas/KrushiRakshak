import 'package:flutter/material.dart';

/// Consolidated app theme, colors and helpers.
class AppColors {
  static const Color primary = Color(0xFF2E7D32); // green
  static const Color secondary = Color(0xFF0288D1); // blue
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFF9A825);
  static const Color danger = Color(0xFFC62828);
  static const Color neutral = Color(0xFFFAFAFA);
}

class AppTheme {
  static ThemeData build(String localeTag) {
    const seed = AppColors.primary;
    final colorScheme = ColorScheme.fromSeed(seedColor: seed);

    final base = ThemeData.from(colorScheme: colorScheme, useMaterial3: true);

    // Use base text theme to avoid runtime font asset loading issues.
    return base.copyWith(
      textTheme: base.textTheme,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      // Card theme handled per-widget to avoid SDK type mismatches.
    );
  }
}
