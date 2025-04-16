import 'package:flutter/material.dart';
import 'package:focusyn_app/constants/theme_constants.dart';
import 'package:focusyn_app/constants/theme_colours.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      textTheme: ThemeConstants.textTheme,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.light,
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      scaffoldBackgroundColor: ThemeColours.scaffoldBackgroundColor,
      iconTheme: const IconThemeData(size: ThemeConstants.iconSize),
      appBarTheme: AppBarTheme(
        backgroundColor: ThemeColours.appBarBackgroundColor,
        iconTheme: const IconThemeData(size: ThemeConstants.appBarIconSize),
        titleTextStyle: TextStyle(
          color: ThemeColours.appBarTextColor,
          fontSize: ThemeConstants.appBarFontSize,
          fontWeight: ThemeConstants.appBarFontWeight,
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
      textTheme: ThemeConstants.textTheme,
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
