import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:focusyn_app/constants/quotes.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:focusyn_app/init/app_data_init.dart';
import 'package:focusyn_app/constants/keys.dart';
import 'package:focusyn_app/firebase_options.dart';
import 'package:focusyn_app/services/notification_service.dart';
import 'package:focusyn_app/models/task_model.dart';

/// Handles the initialization of core application components.
/// This class manages the setup of essential services and data structures
/// required for the app to function properly.
class AppInit {
  /// Initializes all core components of the application.
  /// This method must be called before the app can be used.
  /// It performs the following operations in sequence:
  /// 1. Ensures Flutter bindings are initialized
  /// 2. Sets up Hive for local storage
  /// 3. Initializes Firebase services
  /// 4. Configures notifications
  /// 5. Loads environment variables
  /// 6. Initializes app data
  static Future<void> run() async {
    WidgetsFlutterBinding.ensureInitialized();
    await _initHive();
    await _initFirebase();
    await _initNotifications();
    await dotenv.load();
    await AppDataInit.run();
  }

  /// Initializes Hive for local storage and sets up required boxes.
  /// This method:
  /// 1. Initializes Hive with Flutter
  /// 2. Registers the Task adapter
  /// 3. Opens all required Hive boxes for the app
  static Future<void> _initHive() async {
    await Hive.initFlutter();

    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TaskAdapter());
    }

    // Open boxes
    await Hive.openBox<List>(Keys.taskBox);
    await Hive.openBox(Keys.filterBox);
    await Hive.openBox(Keys.brainBox);
    await Hive.openBox(Keys.historyBox);
    await Hive.openBox(Keys.settingBox);
    await Hive.openBox(Keys.chatBox);
  }

  /// Initializes Firebase services using platform-specific options.
  /// This method sets up Firebase Core with the appropriate configuration
  /// for the current platform (iOS/Android).
  static Future<void> _initFirebase() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  /// Initializes the notification system and schedules daily quote notifications.
  /// This method:
  /// 1. Initializes the notification service
  /// 2. Checks if notifications are enabled in settings
  /// 3. If enabled, schedules a daily quote notification at the configured time
  static Future<void> _initNotifications() async {
    await NotificationService.initialize();
    final box = Hive.box(Keys.settingBox);
    final notificationsEnabled = box.get(
      Keys.notisEnabled,
      defaultValue: false,
    );
    if (notificationsEnabled) {
      final hour = box.get(Keys.notiHour, defaultValue: 9);
      final minute = box.get(Keys.notiMinute, defaultValue: 0);
      await NotificationService.schedule(
        title: 'Daily Quote',
        body: Quotes.getRandomQuote().text,
        hour: hour,
        minute: minute,
      );
    }
  }
}
