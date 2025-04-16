import 'package:flutter/material.dart';
import 'package:focusyn_app/constants/theme_fonts.dart';
import 'package:focusyn_app/constants/theme_colours.dart';

class AppTheme {
  // Theme sizes
  static const double iconSize = 28.0;
  static const double appBarIconSize = 28.0;
  static const double appBarFontSize = 32.0;
  static const FontWeight appBarFontWeight = FontWeight.w900;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      textTheme: ThemeFonts.textTheme,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.light,
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      scaffoldBackgroundColor: ThemeColours.scaffoldBackgroundColor,
      iconTheme: const IconThemeData(size: iconSize),
      appBarTheme: AppBarTheme(
        backgroundColor: ThemeColours.appBarBackgroundColor,
        iconTheme: const IconThemeData(size: appBarIconSize),
        titleTextStyle: TextStyle(
          color: ThemeColours.appBarTextColor,
          fontSize: appBarFontSize,
          fontWeight: appBarFontWeight,
        ),
      ),
      navigationBarTheme: const NavigationBarThemeData(
        indicatorColor: ThemeColours.selectedItemColor,
        backgroundColor: ThemeColours.scaffoldBackgroundColor,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      textTheme: ThemeFonts.textTheme,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.dark,
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      navigationBarTheme: const NavigationBarThemeData(
        indicatorColor: ThemeColours.selectedItemColor,
        backgroundColor: ThemeColours.scaffoldBackgroundColor,
      ),
    );
  }
}
