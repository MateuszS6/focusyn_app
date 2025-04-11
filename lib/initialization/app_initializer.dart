import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:focusyn_app/data/app_data_initializer.dart';
import 'package:focusyn_app/data/keys.dart';
import 'package:focusyn_app/firebase_options.dart';

class AppInitializer {
  static Future<void> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();
    await _initializeHive();
    await _initializeFirebase();
    await AppDataInitializer.run();
  }

  static Future<void> _initializeHive() async {
    await Hive.initFlutter();
    await Hive.openBox(Keys.homeBox);
    await Hive.openBox(Keys.taskBox);
    await Hive.openBox(Keys.filterBox);
  }

  static Future<void> _initializeFirebase() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
}
