import 'package:flutter/material.dart';

/// A collection of color constants used throughout the app for consistent theming.
/// This class defines the color palette for the entire application, including
/// UI elements, focus categories, and task-related colors.
class ThemeColours {
  // UI Colors
  static const Color scaffoldBackgroundColor = Colors.white;
  static const Color appBarBackgroundColor = Colors.white;
  static const Color appBarTextColor = Colors.black;
  static const Color selectedItemColor = Colors.blue;
  static const Color unselectedItemColor = Colors.grey;

  // Focuses Category Colors
  static const Color actionsMain = Colors.purple;
  static const Color actionsAlt = Color(0xFFF3E5F5);
  static const Color flowsMain = Colors.lightGreen;
  static const Color flowsAlt = Color(0xFFE8F5E9);
  static const Color momentsMain = Colors.red;
  static const Color momentsAlt = Color(0xFFFFEBEE);
  static const Color thoughtsMain = Colors.orange;
  static const Color thoughtsAlt = Color(0xFFFFF3E0);

  // Task-related Colors
  static const Color taskMain = Color(0xFF64B5F6);
  static const Color taskAlt = Color(0xFFE3F2FD);
}
