import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:focusyn_app/init/app_data_init.dart';
import 'package:focusyn_app/constants/keys.dart';
import 'package:focusyn_app/firebase_options.dart';

class AppInit {
  static Future<void> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();
    await _initializeHive();
    await _initializeFirebase();
    await AppDataInit.run();
  }

  static Future<void> _initializeHive() async {
    await Hive.initFlutter();
    await Hive.openBox(Keys.brainBox);
    await Hive.openBox(Keys.taskBox);
    await Hive.openBox(Keys.filterBox);
    await Hive.openBox(Keys.settingsBox);
  }

  static Future<void> _initializeFirebase() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
}
