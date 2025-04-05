import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:focusyn_app/data/app_data_initializer.dart';
import 'package:focusyn_app/data/keys.dart';
import 'package:focusyn_app/main_screen.dart';
import 'package:focusyn_app/pages/login_page.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox(Keys.homeBox);
  await Hive.openBox(Keys.taskBox);
  await Hive.openBox(Keys.filterBox);
  await AppDataInitializer.run();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
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

      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: Colors.white,

        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(size: 28),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 32,
            fontWeight: FontWeight.w900,
          ),
        ),

        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
        ),
      ),

      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
        ),
      ),
    );
  }
}
