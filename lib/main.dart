import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:focusyn_app/constants/theme_constants.dart';
import 'package:focusyn_app/initialization/app_initializer.dart';
import 'package:focusyn_app/main_screen.dart';
import 'package:focusyn_app/pages/login_page.dart';

void main() async {
  await AppInitializer.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Focusyn (Beta)',
      debugShowCheckedModeBanner: false,
      // showPerformanceOverlay: true,
      home:
          FirebaseAuth.instance.currentUser == null
              ? const LoginPage()
              : const MainScreen(),

      theme: _buildLightTheme(),

      darkTheme: _buildDarkTheme(),
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      primarySwatch: Colors.blue,
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
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: ThemeConstants.scaffoldBackgroundColor,
        selectedItemColor: ThemeConstants.selectedItemColor,
        unselectedItemColor: ThemeConstants.unselectedItemColor,
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      primarySwatch: Colors.blue,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: ThemeConstants.selectedItemColor,
        unselectedItemColor: ThemeConstants.unselectedItemColor,
      ),
    );
  }
}
