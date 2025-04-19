import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:focusyn_app/constants/quotes.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:focusyn_app/init/app_data_init.dart';
import 'package:focusyn_app/constants/keys.dart';
import 'package:focusyn_app/firebase_options.dart';
import 'package:focusyn_app/services/notification_service.dart';

class AppInit {
  static Future<void> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();
    await _initializeHive();
    await _initializeFirebase();
    await _initializeNotifications();
    await AppDataInit.run();
  }

  static Future<void> _initializeHive() async {
    await Hive.initFlutter();
    await Hive.openBox(Keys.brainBox);
    await Hive.openBox(Keys.taskBox);
    await Hive.openBox(Keys.filterBox);
    await Hive.openBox(Keys.settingBox);
    await Hive.openBox(Keys.chatBox);
  }

  static Future<void> _initializeFirebase() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  static Future<void> _initializeNotifications() async {
    await NotificationService.initialize();
    final box = await Hive.openBox(Keys.settingBox);
    final notificationsEnabled = box.get(
      Keys.notificationsEnabled,
      defaultValue: false,
    );
    if (notificationsEnabled) {
      final hour = box.get(Keys.notificationHour, defaultValue: 9);
      final minute = box.get(Keys.notificationMinute, defaultValue: 0);
      await NotificationService.schedule(
        title: 'Daily Quote',
        body: Quotes.getRandomQuote().text,
        hour: hour,
        minute: minute,
      );
      print('Notification scheduled for $hour:$minute');
    }
  }
}
