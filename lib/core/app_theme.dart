import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const background = Color(0xFF0D0D0D);
  static const panel = Color(0xB312151C);
  static const indigo = Color(0xFF5C6BFF);
  static const amber = Color(0xFFFFB347);
  static const pearl = Color(0xFFF0EDE8);
  static const muted = Color(0xFF8F93A5);
  static const success = Color(0xFF3BD49A);
  static const danger = Color(0xFFFF6174);
  static const border = Color(0x305C6BFF);
}

ThemeData buildTheme() {
  final body = GoogleFonts.dmSansTextTheme(
    ThemeData.dark().textTheme,
  ).apply(bodyColor: AppColors.pearl, displayColor: AppColors.pearl);
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.indigo,
      secondary: AppColors.amber,
      surface: AppColors.panel,
      error: AppColors.danger,
    ),
    textTheme: body.copyWith(
      displayLarge: GoogleFonts.playfairDisplay(
        fontSize: 58,
        fontWeight: FontWeight.w700,
        color: AppColors.pearl,
      ),
      displaySmall: GoogleFonts.playfairDisplay(
        fontSize: 38,
        fontWeight: FontWeight.w700,
      ),
      headlineMedium: GoogleFonts.playfairDisplay(
        fontSize: 30,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: GoogleFonts.playfairDisplay(
        fontSize: 22,
        fontWeight: FontWeight.w600,
      ),
      labelLarge: GoogleFonts.dmSans(fontWeight: FontWeight.w700),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0x80141822),
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
        borderSide: const BorderSide(color: AppColors.indigo, width: 1.5),
      ),
      labelStyle: const TextStyle(color: AppColors.muted),
    ),
    cardTheme: CardThemeData(
      color: AppColors.panel,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.indigo,
        foregroundColor: Colors.white,
        minimumSize: const Size(120, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.pearl,
        minimumSize: const Size(120, 50),
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: const Color(0xFF181B28),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      behavior: SnackBarBehavior.floating,
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
        TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
      },
    ),
  );
}
