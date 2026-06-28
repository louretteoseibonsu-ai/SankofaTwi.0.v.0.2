import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Kente-Modernist palette ───────────────────────────────────────────────
// Grayscale structure + a single vibrant accent (terracotta) reserved for CTAs.
const Color charcoal = Color(0xFF2B2B2D); // primary text / strong structure
const Color slate = Color(0xFF5A5E63); // secondary text / muted accents
const Color silver = Color(0xFFC9CCD1); // borders, Kente mid-tone
const Color silverLight = Color(0xFFE7E9EC); // hairlines, faint Kente
const Color terracotta = Color(0xFFE2725B); // THE accent — CTA buttons only

// ── Legacy aliases (remapped to the grayscale system so screens compile) ──
const Color ink = charcoal;
const Color inkSoft = slate;
const Color canvas = Color(0xFFFFFFFF); // crisp white background
const Color sand = canvas;
const Color surfaceCard = Color(0xFFFFFFFF);
const Color hairline = silverLight;
const Color glyphTile = Color(0xFFF1F2F4); // neutral tile behind glyphs
const Color accentCoral = terracotta;
const Color plantainGreen = slate; // formerly green → neutral structural tone
const Color plantainDeep = charcoal; // formerly deep green → charcoal

// ── Shape (Apple-style squircle) ──────────────────────────────────────────
const ShapeBorder kSquircleCard =
    ContinuousRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(30)));
const RoundedRectangleBorder kButtonShape =
    RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20)));

// Soft, neutral elevation tuned for a white background.
const List<BoxShadow> kSoftShadow = [
  BoxShadow(color: Color(0x14000000), blurRadius: 24, offset: Offset(0, 10)),
  BoxShadow(color: Color(0x0A000000), blurRadius: 3, offset: Offset(0, 1)),
];

ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: terracotta,
    primary: terracotta,
    surface: canvas,
    brightness: Brightness.light,
  ).copyWith(onPrimary: Colors.white);

  final base = ThemeData(useMaterial3: true, colorScheme: scheme);
  final text = GoogleFonts.interTextTheme(base.textTheme).apply(
    bodyColor: charcoal,
    displayColor: charcoal,
  );

  return base.copyWith(
    scaffoldBackgroundColor: canvas,
    textTheme: text,
    splashColor: charcoal.withValues(alpha: 0.05),
    highlightColor: Colors.transparent,
    appBarTheme: AppBarTheme(
      backgroundColor: canvas,
      foregroundColor: charcoal,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle:
          GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 18, color: charcoal),
    ),
    // Primary CTA — the ONLY place terracotta appears.
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: terracotta,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: kButtonShape,
        padding: const EdgeInsets.symmetric(vertical: 17),
        textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: charcoal,
        side: const BorderSide(color: silver),
        shape: kButtonShape,
        padding: const EdgeInsets.symmetric(vertical: 15),
        textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: charcoal,
        textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
      ),
    ),
    // Navigation stays neutral (terracotta is reserved for CTAs).
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: canvas,
      elevation: 0,
      height: 66,
      indicatorColor: silverLight,
      labelTextStyle: WidgetStatePropertyAll(
        GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w600, color: charcoal),
      ),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(color: selected ? charcoal : slate);
      }),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFFAFAFB),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: silver),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: silver),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: charcoal, width: 1.6),
      ),
      labelStyle: const TextStyle(color: slate),
    ),
    dividerTheme: const DividerThemeData(color: silverLight, thickness: 1),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: charcoal,
      contentTextStyle: GoogleFonts.inter(color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  );
}
