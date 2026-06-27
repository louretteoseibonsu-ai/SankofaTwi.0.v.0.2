import 'package:flutter/material.dart';

/// Design tokens (calm-technology, heritage-premium).
const Color plantainGreen = Color(0xFF2E8B57);
const Color plantainDeep = Color(0xFF1F6B41);
const Color accentCoral = Color(0xFFE2725B);
const Color sand = Color(0xFFF6F1E7);
const Color ink = Color(0xFF1C1B19);
const Color glyphTile = Color(0xFFEFF7F1);

ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: plantainGreen,
    primary: plantainGreen,
    secondary: accentCoral,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: sand,
    appBarTheme: const AppBarTheme(
      backgroundColor: sand,
      foregroundColor: ink,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: plantainGreen,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        padding: const EdgeInsets.symmetric(vertical: 16),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
      ),
    ),
  );
}
