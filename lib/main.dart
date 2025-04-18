import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:focusyn_app/constants/keys.dart';
import 'package:focusyn_app/init/app_init.dart';
import 'package:focusyn_app/main_screen.dart';
import 'package:focusyn_app/pages/login_page.dart';
import 'package:focusyn_app/pages/onboarding_page.dart';
import 'package:focusyn_app/theme/app_theme.dart';
import 'package:hive/hive.dart';

void main() async {
  await AppInit.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Keys.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: _getInitialScreen(),
    );
  }

  Widget _getInitialScreen() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return const LoginPage();
    }

    // Check if onboarding is completed
    final settingsBox = Hive.box(Keys.settingBox);
    final onboardingCompleted = settingsBox.get(
      'onboardingCompleted',
      defaultValue: false,
    );

    return onboardingCompleted ? const MainScreen() : const OnboardingPage();
  }
}
