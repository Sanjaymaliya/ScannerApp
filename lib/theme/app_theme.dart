
import 'package:flutter/material.dart';

import 'app_text_styles.dart';

class AppTheme {
  AppTheme._();

  static const Color primary = Color(0xFF1A1F36);
  static const Color accent = Color(0xFF4F6EF7);
  static const Color accentGreen = Color(0xFF22C55E);
  static const Color accentRed = Color(0xFFEF4444);
  static const Color surface = Color(0xFFF8FAFF);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color divider = Color(0xFFE2E8F0);

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: accent,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: surface,
        appBarTheme: const AppBarTheme(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        cardTheme: CardThemeData(
          color: cardBg,
          elevation: 2,
          shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: accent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: accent,
            side: const BorderSide(color: accent, width: 1.5),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
        textTheme: _buildTextTheme(textPrimary, textSecondary),
      );


  static TextTheme _buildTextTheme(Color txtPrimary, Color secondary) => TextTheme(
    displayLarge: AppTextStyles.txtTitle.copyWith(color: txtPrimary),
    displayMedium: AppTextStyles.subTitle.copyWith(color: secondary),
    headlineLarge: AppTextStyles.headingLarge.copyWith(color: txtPrimary),
    headlineMedium: AppTextStyles.headingMedium.copyWith(color: secondary),

  );
}
