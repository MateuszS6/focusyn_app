import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:focusyn_app/constants/quotes.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:focusyn_app/constants/keys.dart';
import 'package:hive/hive.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static bool _isInitialized = false;

  static Future<void> init() async {
    if (_isInitialized) return;

    // Set the local timezone
    tz.setLocalLocation(tz.getLocation('Europe/London')); // Default timezone

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap
        debugPrint('Notification tapped: ${response.payload}');
        // TODO: Navigate to appropriate screen when notification is tapped
      },
    );

    _isInitialized = true;
    debugPrint('Notification service initialized');
  }

  static Future<bool> requestPermissions() async {
    if (!_isInitialized) {
      await init();
    }

    // For Android 8, we don't need to request permissions at runtime
    // This is only needed for Android 13+
    debugPrint('Permissions requested');
    return true;
  }

  static Future<void> restoreFromSettings() async {
    debugPrint('Restoring notification settings from storage');
    final box = Hive.box(Keys.notificationBox);
    final enabled = box.get('notifications', defaultValue: false);
    final hour = box.get('notificationHour', defaultValue: 9);
    final min = box.get('notificationMinute', defaultValue: 0);

    await scheduleQuoteNotification(
      hour: hour,
      minute: min,
      isEnabled: enabled,
    );
  }

  static Future<void> scheduleQuoteNotification({
    required int hour,
    required int minute,
    required bool isEnabled,
  }) async {
    if (!_isInitialized) {
      await init();
    }

    // Cancel existing notifications first
    await cancelAllNotifications();

    if (!isEnabled) {
      debugPrint('Notifications disabled');
      return;
    }

    // Get a random quote
    final random = Random();
    final quote = Quotes.getRandomQuote();

    // Schedule the notification
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // If the time has already passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    debugPrint('Scheduling notification for $scheduledDate');

    try {
      await _plugin.zonedSchedule(
        0, // Notification ID
        "How are you doing?",
        quote.text,
        scheduledDate,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'focusyn_quotes_channel',
            'Focusyn Quotes',
            channelDescription: 'Daily motivational quotes from Focusyn',
            importance: Importance.high,
            priority: Priority.high,
            enableVibration: true,
            enableLights: true,
            color: Colors.blue,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time, // Repeat daily
        payload:
            'quote_notification', // Add payload for handling notification taps
      );

      debugPrint(
        'Quote notification scheduled successfully for $scheduledDate',
      );
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
    }
  }

  static Future<void> cancelAllNotifications() async {
    if (!_isInitialized) {
      await init();
    }

    await _plugin.cancelAll();
    debugPrint('All notifications cancelled');
  }

  static Future<bool> areNotificationsEnabled() async {
    if (!_isInitialized) {
      await init();
    }

    final androidSettings =
        await _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    if (androidSettings != null) {
      return await androidSettings.areNotificationsEnabled() ?? false;
    }

    return false;
  }
}
