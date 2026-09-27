// lib/core/theme/app_theme.dart
// KneeVib design system — calm, accessible, high-contrast.

import 'package:flutter/material.dart';

// ─── Brand colours ───────────────────────────────────────────────────────────
const _seedColor = Color(0xFF1A73E8); // clear blue — calm, medical

const _green = Color(0xFF2E7D32);
const _greenLight = Color(0xFF4CAF50);
const _yellow = Color(0xFFF57F17);
const _yellowLight = Color(0xFFFFB300);
const _red = Color(0xFFC62828);
const _redLight = Color(0xFFEF5350);

// Score badge colours (shared, used in both modes)
class ScoreColors {
  static Color badge(double score, bool isDark) {
    if (score <= 3.5) return isDark ? _greenLight : _green;
    if (score <= 6.5) return isDark ? _yellowLight : _yellow;
    return isDark ? _redLight : _red;
  }

  static Color badgeText(double score) {
    if (score <= 3.5) return Colors.white;
    if (score <= 6.5) return Colors.black;
    return Colors.white;
  }

  static String label(double score) {
    if (score <= 3.5) return 'GOOD';
    if (score <= 6.5) return 'MODERATE';
    return 'HIGH';
  }
}

// ─── Light theme ─────────────────────────────────────────────────────────────
ThemeData get lightTheme => ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _seedColor,
        brightness: Brightness.light,
      ),
      textTheme: _textTheme,
      appBarTheme: const AppBarTheme(centerTitle: false),
      filledButtonTheme: _filledButtonTheme,
      cardTheme: _cardTheme,
      elevatedButtonTheme: _elevatedButtonTheme,
      inputDecorationTheme: _inputDecorationTheme,
    );

// ─── Dark theme ──────────────────────────────────────────────────────────────
ThemeData get darkTheme => ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _seedColor,
        brightness: Brightness.dark,
      ),
      textTheme: _textTheme,
      appBarTheme: const AppBarTheme(centerTitle: false),
      filledButtonTheme: _filledButtonTheme,
      cardTheme: _cardTheme,
      elevatedButtonTheme: _elevatedButtonTheme,
      inputDecorationTheme: _inputDecorationTheme,
    );

// ─── Shared overrides ────────────────────────────────────────────────────────

final _textTheme = const TextTheme(
  displayLarge: TextStyle(fontSize: 57, fontWeight: FontWeight.w300),
  titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
  titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
  bodyLarge: TextStyle(fontSize: 18),    // enlarged for accessibility
  bodyMedium: TextStyle(fontSize: 16),
  bodySmall: TextStyle(fontSize: 14),
  labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
);

final _filledButtonTheme = FilledButtonThemeData(
  style: FilledButton.styleFrom(
    minimumSize: const Size(120, 52), // large touch targets
    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
);

final _elevatedButtonTheme = ElevatedButtonThemeData(
  style: ElevatedButton.styleFrom(
    minimumSize: const Size(120, 52),
    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
);

final _cardTheme = CardThemeData(
  elevation: 2,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
);

final _inputDecorationTheme = InputDecorationTheme(
  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
);
