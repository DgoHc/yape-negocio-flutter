import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color backgroundColor = Color(0xFFF8F9FD);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color primaryColor = Color(0xFFFFC93C);
  static const Color secondaryColor = Color(0xFFFFF0B3);
  static const Color textPrimary = Color(0xFF1E1B18);
  static const Color textSecondary = Color(0xFF717488);
  static const Color textPlaceholder = Color(0xFFA2A5B8);
  static const Color successColor = Color(0xFF22C55E);
  static const Color errorColor = Color(0xFFEF4444);

  static List<BoxShadow> softProShadow({
    double intensity = 1.0,
    Color? shadowColor,
  }) {
    final color = shadowColor ?? const Color(0xFF0F172A);
    return [
      BoxShadow(
        color: color.withValues(alpha: 0.06 * intensity),
        blurRadius: 24,
        offset: const Offset(0, 10),
        spreadRadius: 0,
      ),
      BoxShadow(
        color: color.withValues(alpha: 0.03 * intensity),
        blurRadius: 8,
        offset: const Offset(0, 2),
        spreadRadius: 0,
      ),
    ];
  }

  static List<BoxShadow> clayShadow({
    required Color baseColor,
    bool isPressed = false,
    double intensity = 1.0,
  }) {
    if (isPressed) {
      return [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04 * intensity),
          offset: const Offset(1, 1),
          blurRadius: 4,
          spreadRadius: 0,
        ),
      ];
    }
    return softProShadow(intensity: intensity);
  }

  static ThemeData get darkTheme => lightTheme;

  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.plusJakartaSansTextTheme();
    
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: backgroundColor,
      primaryColor: primaryColor,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        error: errorColor,
        onPrimary: textPrimary,
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: GoogleFonts.plusJakartaSans(
          fontSize: 34,
          fontWeight: FontWeight.w800,
          color: textPrimary,
          letterSpacing: -0.8,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
        headlineMedium: GoogleFonts.plusJakartaSans(
          fontSize: 26,
          fontWeight: FontWeight.w800,
          color: textPrimary,
          letterSpacing: -0.5,
        ),
        titleLarge: GoogleFonts.plusJakartaSans(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: -0.3,
        ),
        titleMedium: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          fontWeight: FontWeight.w700,
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
          fontWeight: FontWeight.w600,
          color: textSecondary,
        ),
        labelSmall: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w500,
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
          fontWeight: FontWeight.w800,
          fontFamily: 'Plus Jakarta Sans',
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
