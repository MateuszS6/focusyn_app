// Core Flutter imports
import 'package:flutter/material.dart';

// Firebase authentication
import 'package:firebase_auth/firebase_auth.dart';

// Application-specific imports
import 'package:focusyn_app/constants/keys.dart'; // Application constants
import 'package:focusyn_app/init/app_init.dart'; // Application initialization
import 'package:focusyn_app/main_screen.dart'; // Main application screen
import 'package:focusyn_app/pages/login_page.dart'; // User authentication
import 'package:focusyn_app/pages/onboarding_page.dart'; // First-time user experience
import 'package:focusyn_app/services/setting_service.dart';
import 'package:focusyn_app/theme/app_theme.dart'; // Application theming

/// The entry point of the Focusyn application.
///
/// This function:
/// 1. Initializes the application by calling [AppInit.initialize]
/// 2. Runs the application with [MyApp] as the root widget
///
/// The initialization process includes:
/// - Setting up Hive for local storage
/// - Configuring Firebase
/// - Loading application settings
/// - Preparing theme data
void main() async {
  await AppInit.initialize();
  runApp(const MyApp());
}

/// The root widget of the Focusyn application.
///
/// This widget:
/// - Configures the MaterialApp with theme settings
/// - Determines the initial screen based on user state
/// - Handles dark/light theme switching
///
/// The application supports:
/// - Custom light and dark themes
/// - Debug mode configuration
/// - Dynamic initial screen routing
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Keys.appName, // Focusyn
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme, // Light theme
      darkTheme:
          AppTheme.darkTheme, // Dark theme (functionality not implemented)
      home: _getInitialScreen(),
    );
  }

  /// Determines the appropriate initial screen based on user state.
  ///
  /// This method implements the following routing logic:
  /// 1. If no user is logged in:
  ///    - Returns [SigninPage] for authentication
  /// 2. If user is logged in:
  ///    - Checks if onboarding is completed
  ///    - Returns [OnboardingPage] if not completed
  ///    - Returns [MainScreen] if onboarding is completed
  ///
  /// The routing decision is based on:
  /// - Firebase authentication state
  /// - Local storage settings for onboarding
  Widget _getInitialScreen() {
    // Check authentication state
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return const SigninPage();
    }

    // Route to appropriate screen
    return SettingService.isOnboardingDone() ? const MainScreen() : const OnboardingPage();
  }
}
