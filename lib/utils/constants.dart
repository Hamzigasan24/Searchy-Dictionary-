import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── PHP Backend base URL ──────────────────────────────────────────────────────
const String kApiBaseUrl = 'http://YOUR_SERVER/searchy_api';

// ── Color System ─────────────────────────────────────────────────────────────
class AppColors {
  // Deep indigo — used for headers, hero sections
  static const headerBg    = Color(0xFF1E1B4B);
  static const headerBgAlt = Color(0xFF312E81);

  // Brand
  static const primary      = Color(0xFF4F46E5);
  static const primaryLight = Color(0xFFEEF2FF);

  // Accent — amber gold
  static const accent      = Color(0xFFF59E0B);
  static const accentLight = Color(0xFFFFFBEB);

  // Backgrounds
  static const background = Color(0xFFF8FAFC);
  static const surface    = Color(0xFFFFFFFF);
  static const surfaceAlt = Color(0xFFF1F5F9);

  // Text
  static const textPrimary   = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF64748B);
  static const textLight     = Color(0xFFCBD5E1);

  // Status
  static const success = Color(0xFF10B981);
  static const error   = Color(0xFFEF4444);
  static const warning = Color(0xFFF59E0B);

  // UI chrome
  static const border  = Color(0xFFE2E8F0);
  static const divider = Color(0xFFF1F5F9);
  static const shadow  = Color(0x144F46E5);

  // POS tag palette
  static const posNoun       = Color(0xFF3B82F6); // blue
  static const posVerb       = Color(0xFF10B981); // emerald
  static const posAdjective  = Color(0xFF8B5CF6); // violet
  static const posAdverb     = Color(0xFFF59E0B); // amber
  static const posOther      = Color(0xFF6B7280); // gray

  // Gradient helpers
  static const Gradient headerGradient = LinearGradient(
    colors: [headerBg, headerBgAlt],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient primaryGradient = LinearGradient(
    colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient accentGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

// ── Typography ────────────────────────────────────────────────────────────────
class T {
  static TextStyle display({Color color = AppColors.textPrimary}) =>
      GoogleFonts.outfit(
        fontSize: 34, fontWeight: FontWeight.w800,
        color: color, letterSpacing: -0.5, height: 1.15,
      );

  static TextStyle headline({Color color = AppColors.textPrimary}) =>
      GoogleFonts.outfit(
        fontSize: 24, fontWeight: FontWeight.w700,
        color: color, letterSpacing: -0.3,
      );

  static TextStyle title({Color color = AppColors.textPrimary}) =>
      GoogleFonts.outfit(
        fontSize: 18, fontWeight: FontWeight.w600,
        color: color,
      );

  static TextStyle subtitle({Color color = AppColors.textSecondary}) =>
      GoogleFonts.outfit(
        fontSize: 15, fontWeight: FontWeight.w400,
        color: color, height: 1.5,
      );

  static TextStyle body({Color color = AppColors.textPrimary}) =>
      GoogleFonts.outfit(
        fontSize: 15, fontWeight: FontWeight.w400,
        color: color, height: 1.65,
      );

  static TextStyle label({Color color = AppColors.textSecondary}) =>
      GoogleFonts.outfit(
        fontSize: 13, fontWeight: FontWeight.w500,
        color: color,
      );

  static TextStyle caption({Color color = AppColors.textLight}) =>
      GoogleFonts.outfit(
        fontSize: 12, fontWeight: FontWeight.w400,
        color: color,
      );
}

// Keep for backward compat if any file still references AppTextStyles
class AppTextStyles {
  static TextStyle get headline => T.headline();
  static TextStyle get subtitle => T.subtitle();
  static TextStyle get body => T.body();
  static TextStyle get caption => T.caption();
}

// ── Theme ─────────────────────────────────────────────────────────────────────
ThemeData appTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: AppColors.background,
  );

  return base.copyWith(
    textTheme: GoogleFonts.outfitTextTheme(base.textTheme),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      iconTheme: const IconThemeData(color: AppColors.textPrimary),
      titleTextStyle: GoogleFonts.outfit(
        fontSize: 20, fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceAlt,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      labelStyle: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 14),
      hintStyle: GoogleFonts.outfit(color: AppColors.textLight, fontSize: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 0,
        textStyle: GoogleFonts.outfit(
          fontSize: 16, fontWeight: FontWeight.w600,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: AppColors.primary),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
    ),
  );
}

// ── Helpers ───────────────────────────────────────────────────────────────────
Color posColor(String pos) {
  switch (pos.toLowerCase()) {
    case 'noun':        return AppColors.posNoun;
    case 'verb':        return AppColors.posVerb;
    case 'adjective':   return AppColors.posAdjective;
    case 'adverb':      return AppColors.posAdverb;
    default:            return AppColors.posOther;
  }
}
