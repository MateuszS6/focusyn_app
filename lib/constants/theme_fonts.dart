import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Manages the typography system for the application.
/// This class defines font families and text styles used throughout the app,
/// utilizing Google Fonts for consistent and modern typography.
class ThemeFonts {
  /// Font used for large, prominent text (Outfit).
  static final displayFont = GoogleFonts.outfit;

  /// Font used for section headers (Poppins).
  static final headlineFont = GoogleFonts.poppins;

  /// Font used for titles and important text (Inter).
  static final titleFont = GoogleFonts.inter;

  /// Font used for regular content (Inter).
  static final bodyFont = GoogleFonts.inter;

  /// Font used for small labels and captions (Inter).
  static final labelFont = GoogleFonts.inter;

  /// Returns a complete TextTheme with predefined styles for different text elements.
  /// The theme includes large, medium, and small styles for:
  /// - Display text
  /// - Headlines
  /// - Titles
  /// - Body text
  /// - Labels
  static TextTheme get textTheme {
    return TextTheme(
      // Display styles - Used for the largest text elements
      displayLarge: displayFont(fontSize: 36, fontWeight: FontWeight.w600),
      displayMedium: displayFont(fontSize: 28, fontWeight: FontWeight.w600),
      displaySmall: displayFont(fontSize: 24, fontWeight: FontWeight.w600),

      // Headline styles - Used for section headers
      headlineLarge: headlineFont(fontSize: 20, fontWeight: FontWeight.w600),
      headlineMedium: headlineFont(fontSize: 18, fontWeight: FontWeight.w600),
      headlineSmall: headlineFont(fontSize: 16, fontWeight: FontWeight.w600),

      // Title styles - Used for content titles
      titleLarge: titleFont(fontSize: 16, fontWeight: FontWeight.w500),
      titleMedium: titleFont(fontSize: 14, fontWeight: FontWeight.w500),
      titleSmall: titleFont(fontSize: 12, fontWeight: FontWeight.w500),

      // Body styles - Used for regular content
      bodyLarge: bodyFont(fontSize: 16, fontWeight: FontWeight.normal),
      bodyMedium: bodyFont(fontSize: 14, fontWeight: FontWeight.normal),
      bodySmall: bodyFont(fontSize: 12, fontWeight: FontWeight.normal),

      // Label styles - Used for small text elements
      labelLarge: labelFont(fontSize: 14, fontWeight: FontWeight.w500),
      labelMedium: labelFont(fontSize: 12, fontWeight: FontWeight.w500),
      labelSmall: labelFont(fontSize: 10, fontWeight: FontWeight.w500),
    );
  }
}
