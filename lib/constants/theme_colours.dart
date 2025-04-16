import 'package:flutter/material.dart';
import 'package:focusyn_app/constants/keys.dart';

class ThemeColours {
  // UI
  static const Color scaffoldBackgroundColor = Colors.white;
  static const Color appBarBackgroundColor = Colors.white;
  static const Color appBarTextColor = Colors.black;
  static const Color selectedItemColor = Colors.blue;
  static const Color unselectedItemColor = Colors.grey;

  // Focuses
  static const Color actionsMain = Colors.purple;
  static const Color actionsTask = Color(0xFFF3E5F5);
  static const Color flowsMain = Colors.lightGreen;
  static const Color flowsTask = Color(0xFFE8F5E9);
  static const Color momentsMain = Colors.red;
  static const Color momentsTask = Color(0xFFFFEBEE);
  static const Color thoughtsMain = Colors.orange;
  static const Color thoughtsTask = Color(0xFFE3F2FD);

  // Tasks
  static const Color taskMain = Colors.blue;
  static const Color taskTask = Color(0xFFE3F2FD);

  static const Map<String, Map<String, Color>> focusColors = {
    Keys.actions: {'main': Colors.purple, 'task': Color(0xFFF3E5F5)},
    Keys.flows: {'main': Colors.lightGreen, 'task': Color(0xFFE8F5E9)},
    Keys.moments: {'main': Colors.red, 'task': Color(0xFFFFEBEE)},
    Keys.thoughts: {'main': Colors.orange, 'task': Color(0xFFE3F2FD)},
  };
}
