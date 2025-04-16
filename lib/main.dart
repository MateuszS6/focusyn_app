import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:focusyn_app/constants/keys.dart';
import 'package:focusyn_app/init/app_init.dart';
import 'package:focusyn_app/main_screen.dart';
import 'package:focusyn_app/pages/login_page.dart';
import 'package:focusyn_app/theme/app_theme.dart';

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
      home:
          FirebaseAuth.instance.currentUser == null
              ? const LoginPage()
              : const MainScreen(),
    );
  }
}
