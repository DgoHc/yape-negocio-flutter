import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color backgroundColor = Color(0xFFFFFDF5);
  static const Color surfaceColor = Color(0xFFFFF4CC);
  static const Color primaryColor = Color(0xFFFFC93C);
  static const Color secondaryColor = Color(0xFFFFDE7D);
  static const Color textPrimary = Color(0xFF2D2100);
  static const Color textSecondary = Color(0xFF8A7A4A);
  static const Color textPlaceholder = Color(0xFFB0A070);
  static const Color successColor = Color(0xFF6FCF97);
  static const Color errorColor = Color(0xFFE85D5D);

  static List<BoxShadow> clayShadow({
    required Color baseColor,
    bool isPressed = false,
    double intensity = 1.0,
  }) {
    if (isPressed) {
      return [
        BoxShadow(
          color: Colors.black.withOpacity(0.05 * intensity),
          offset: const Offset(2, 2),
          blurRadius: 4,
          spreadRadius: 1,
        ),
        BoxShadow(
          color: Colors.white.withOpacity(0.5 * intensity),
          offset: const Offset(-2, -2),
          blurRadius: 4,
        ),
      ];
    }
    
    return [
      BoxShadow(
        color: Colors.white.withOpacity(0.8 * intensity),
        offset: const Offset(-5, -5),
        blurRadius: 10,
      ),
      BoxShadow(
        color: Color.lerp(baseColor, Colors.black, 0.2)!.withOpacity(0.15 * intensity),
        offset: const Offset(5, 5),
        blurRadius: 12,
      ),
    ];
  }

  static ThemeData get darkTheme => lightTheme;

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
          fontSize: 34,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: -0.5,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
        headlineMedium: GoogleFonts.plusJakartaSans(
          fontSize: 26,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleLarge: GoogleFonts.plusJakartaSans(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleMedium: GoogleFonts.plusJakartaSans(
          fontSize: 16,
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
        labelMedium: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w500,
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

extension ColorExtension on Color {
  Color withValues({double? alpha}) {
    if (alpha == null) return this;
    return withOpacity(alpha);
  }
}
