import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:focusyn_app/init/app_data_init.dart';
import 'package:focusyn_app/constants/keys.dart';
import 'package:focusyn_app/firebase_options.dart';
import 'package:focusyn_app/services/notification_service.dart';
import 'package:timezone/data/latest.dart' as tz;

class AppInit {
  static Future<void> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();
    tz.initializeTimeZones();
    await _initializeHive();
    await _initializeFirebase();
    await NotificationService.init();
    await NotificationService.requestPermissions();
    await NotificationService.restoreFromSettings();
    await AppDataInit.run();
  }

  static Future<void> _initializeHive() async {
    await Hive.initFlutter();
    await Hive.openBox(Keys.brainBox);
    await Hive.openBox(Keys.taskBox);
    await Hive.openBox(Keys.filterBox);
    await Hive.openBox(Keys.notificationBox);
  }

  static Future<void> _initializeFirebase() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
}
