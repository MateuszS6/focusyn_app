import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeFonts {
  // Font families
  static final displayFont = GoogleFonts.outfit;
  static final headlineFont = GoogleFonts.poppins;
  static final titleFont = GoogleFonts.inter;
  static final bodyFont = GoogleFonts.inter;
  static final labelFont = GoogleFonts.inter;

  static TextTheme get textTheme {
    return TextTheme(
      // Display styles
      displayLarge: displayFont(fontSize: 36, fontWeight: FontWeight.w600),
      displayMedium: displayFont(fontSize: 28, fontWeight: FontWeight.w600),
      displaySmall: displayFont(fontSize: 24, fontWeight: FontWeight.w600),

      // Headline styles
      headlineLarge: headlineFont(fontSize: 20, fontWeight: FontWeight.w600),
      headlineMedium: headlineFont(fontSize: 18, fontWeight: FontWeight.w600),
      headlineSmall: headlineFont(fontSize: 16, fontWeight: FontWeight.w600),

      // Title styles
      titleLarge: titleFont(fontSize: 16, fontWeight: FontWeight.w500),
      titleMedium: titleFont(fontSize: 14, fontWeight: FontWeight.w500),
      titleSmall: titleFont(fontSize: 12, fontWeight: FontWeight.w500),

      // Body styles
      bodyLarge: bodyFont(fontSize: 16, fontWeight: FontWeight.normal),
      bodyMedium: bodyFont(fontSize: 14, fontWeight: FontWeight.normal),
      bodySmall: bodyFont(fontSize: 12, fontWeight: FontWeight.normal),

      // Label styles
      labelLarge: labelFont(fontSize: 14, fontWeight: FontWeight.w500),
      labelMedium: labelFont(fontSize: 12, fontWeight: FontWeight.w500),
      labelSmall: labelFont(fontSize: 10, fontWeight: FontWeight.w500),
    );
  }
}
