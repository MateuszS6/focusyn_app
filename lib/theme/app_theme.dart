import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:focusyn_app/constants/theme_constants.dart';

class AppTheme {
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

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      textTheme: textTheme,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.light,
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      scaffoldBackgroundColor: ThemeConstants.scaffoldBackgroundColor,
      iconTheme: const IconThemeData(size: ThemeConstants.iconSize),
      appBarTheme: AppBarTheme(
        backgroundColor: ThemeConstants.appBarBackgroundColor,
        iconTheme: const IconThemeData(size: ThemeConstants.appBarIconSize),
        titleTextStyle: TextStyle(
          color: ThemeConstants.appBarTextColor,
          fontSize: ThemeConstants.appBarFontSize,
          fontWeight: ThemeConstants.appBarFontWeight,
        ),
      ),
      navigationBarTheme: const NavigationBarThemeData(
        indicatorColor: ThemeConstants.selectedItemColor,
        backgroundColor: ThemeConstants.scaffoldBackgroundColor,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      textTheme: textTheme,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.dark,
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      navigationBarTheme: const NavigationBarThemeData(
        indicatorColor: ThemeConstants.selectedItemColor,
        backgroundColor: ThemeConstants.scaffoldBackgroundColor,
      ),
    );
  }
}
