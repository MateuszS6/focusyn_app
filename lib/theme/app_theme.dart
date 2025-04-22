import 'package:flutter/material.dart';
import 'package:focusyn_app/constants/theme_fonts.dart';
import 'package:focusyn_app/constants/theme_colours.dart';

/// Manages the application's theme configuration.
/// This class defines the visual appearance of the app, including:
/// - Light and dark theme variants
/// - Consistent sizing for UI elements
/// - Typography and color schemes
/// - Platform-specific visual density
class AppTheme {
  /// Standard size for icons throughout the app
  static const double iconSize = 28.0;

  /// Returns the light theme configuration for the application.
  ///
  /// This theme includes:
  /// - Material 3 design system
  /// - Custom text theme from ThemeFonts
  /// - Blue-based color scheme
  /// - Platform-adaptive visual density
  /// - Custom scaffold and app bar styling
  /// - Navigation bar theming
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
        iconTheme: const IconThemeData(size: iconSize),
        titleTextStyle: TextStyle(color: ThemeColours.appBarTextColor),
      ),
      navigationBarTheme: const NavigationBarThemeData(
        indicatorColor: ThemeColours.selectedItemColor,
        backgroundColor: ThemeColours.scaffoldBackgroundColor,
      ),
    );
  }

  /// Returns the dark theme configuration for the application.
  ///
  /// This theme includes:
  /// - Material 3 design system
  /// - Custom text theme from ThemeFonts
  /// - Blue-based color scheme with dark brightness
  /// - Platform-adaptive visual density
  /// - Navigation bar theming
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
