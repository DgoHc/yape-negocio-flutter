import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

class AppTheme {
  // Paleta Claymorphism Amarilla
  static const Color backgroundColor = Color(0xFFFFF4CC);
  static const Color primaryColor = Color(0xFFFFC93C);
  static const Color secondaryColor = Color(0xFFFFDE7D);
  static const Color surfaceColor = Color(0xFFFFFDF5);
  
  static const Color textPrimary = Color(0 sneak4A3B00);
  static const Color textSecondary = Color(0xFF7A5C00);
  
  static const Color successColor = Color(0xFF6FCF97);
  static const Color errorColor = Color(0xFFE85D5D);

  // Sombras Clay
  static List<BoxShadow> clayShadow({
    required Color baseColor,
    bool isPressed = false,
  }) {
    if (isPressed) {
      return [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          offset: const Offset(4, 4),
          blurRadius: 10,
          spreadRadius: -2,
        ),
        BoxShadow(
          color: Colors.white.withValues(alpha: 0.7),
          offset: const Offset(-4, -4),
          blurRadius: 10,
        ),
      ];
    }
    
    return [
      BoxShadow(
        color: Colors.white.withValues(alpha: 0.6),
        offset: const Offset(-6, -6),
        blurRadius: 12,
      ),
      BoxShadow(
        color: Color.lerp(baseColor, Colors.black, 0.3)!.withValues(alpha: 0.3),
        offset: const Offset(6, 6),
        blurRadius: 14,
      ),
    ];
  }

  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.plusJakartaSansTextTheme();
    
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: backgroundColor,
      primaryColor: primaryColor,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        error: errorColor,
        onPrimary: textPrimary,
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: GoogleFonts.plusJakartaSans(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          letterSpacing: -0.5,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
        titleLarge: GoogleFonts.plusJakartaSans(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        bodyLarge: GoogleFonts.plusJakartaSans(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: textPrimary,
          height: 1.4,
        ),
        bodyMedium: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          color: textSecondary,
        ),
        labelSmall: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          color: textSecondary,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),
    );
  }
}
