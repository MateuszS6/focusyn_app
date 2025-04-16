import 'package:flutter/material.dart';
import 'package:focusyn_app/constants/keys.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeConstants {
  // Theme sizes
  static const double iconSize = 28.0;
  static const double appBarIconSize = 28.0;
  static const double appBarFontSize = 32.0;
  static const FontWeight appBarFontWeight = FontWeight.w900;

  // Theme colours
  static const Color scaffoldBackgroundColor = Colors.white;
  static const Color appBarBackgroundColor = Colors.white;
  static const Color appBarTextColor = Colors.black;
  static const Color selectedItemColor = Colors.blue;
  static const Color unselectedItemColor = Colors.grey;

  // Focus colours
  static const Map<String, Map<String, Color>> focusColors = {
    Keys.actions: {'main': Colors.purple, 'task': Color(0xFFF3E5F5)},
    Keys.flows: {'main': Colors.lightGreen, 'task': Color(0xFFE8F5E9)},
    Keys.moments: {'main': Colors.red, 'task': Color(0xFFFFEBEE)},
    Keys.thoughts: {'main': Colors.orange, 'task': Color(0xFFE3F2FD)},
  };

  // Text styles
  static TextTheme get textTheme {
    // Font families
    final displayFont = GoogleFonts.outfit;
    final headlineFont = GoogleFonts.poppins;
    final titleFont = GoogleFonts.inter;
    final bodyFont = GoogleFonts.inter;
    final labelFont = GoogleFonts.inter;

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
