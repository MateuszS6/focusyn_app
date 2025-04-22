import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

/// A service class for managing local notifications in the app.
///
/// This implementation is based on Mitch Koko's Flutter notification tutorials:
/// - [Local Notifications in Flutter](https://youtu.be/uKz8tWbMuUw?si=-V7rLJubMZdYQ-6F)
/// - [Scheduled Notifications in Flutter](https://youtu.be/i98p9dJ4lhI?si=YUXKikk1PeaFexdH)
///
/// The service provides functionality for:
/// - Initializing the notification system
/// - Showing immediate notifications
/// - Scheduling notifications for specific times
/// - Managing notification channels
/// - Canceling notifications
class NotificationService {
  /// Instance of FlutterLocalNotificationsPlugin for managing notifications
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Flag to track if the notification service has been initialized
  static bool _isInitialized = false;

  /// Getter to check if the notification service is initialized
  static bool get isInitialized => _isInitialized;

  /// Initializes the notification service.
  /// This method:
  /// - Sets up the timezone
  /// - Creates the Android notification channel
  /// - Initializes the notification plugin
  ///
  /// Throws an exception if:
  /// - Timezone initialization fails
  /// - Channel creation fails
  static Future<void> initialize() async {
    if (_isInitialized) return; // Already initialized

    // Initialize timezone
    tz.initializeTimeZones();
    String currentTimeZone = 'Europe/London';
    try {
      currentTimeZone = await FlutterTimezone.getLocalTimezone();
    } catch (e) {
      throw Exception('Error getting local timezone, defaulting to London: $e');
    }
    tz.setLocalLocation(tz.getLocation(currentTimeZone));

    // Create the Android notification channel
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            'daily_channel_id',
            'Daily Notification',
            description: 'Daily Notification Channel',
            importance: Importance.max,
          ),
        );

    _isInitialized = true;
  }

  /// Gets the notification details for both Android and iOS platforms.
  ///
  /// Returns a [NotificationDetails] object with:
  /// - Android-specific settings (channel, importance, priority, etc.)
  /// - iOS-specific settings (alert, badge, sound)
  static NotificationDetails _getNotificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'daily_channel_id',
        'Daily Notification',
        channelDescription: 'Daily Notification Channel',
        importance: Importance.max,
        priority: Priority.high,
        showProgress: true,
        enableVibration: true,
        enableLights: true,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
  }

  /// Shows an immediate notification.
  ///
  /// [id] - Unique identifier for the notification (defaults to 0)
  /// [title] - The title of the notification
  /// [body] - The body text of the notification
  ///
  /// Throws an exception if:
  /// - Notification service is not initialized
  /// - Notification display fails
  static Future<void> show({int id = 0, String? title, String? body}) async {
    if (!_isInitialized) await initialize();

    return _notificationsPlugin.show(
      id,
      title,
      body,
      _getNotificationDetails(),
    );
  }

  /// Schedules a notification for a specific time.
  ///
  /// [id] - Unique identifier for the notification (defaults to 0)
  /// [title] - The title of the notification
  /// [body] - The body text of the notification
  /// [hour] - The hour to schedule the notification (24-hour format)
  /// [minute] - The minute to schedule the notification
  ///
  /// If the specified time has already passed for the current day,
  /// the notification will be scheduled for the next day.
  ///
  /// Throws an exception if:
  /// - Notification service is not initialized
  /// - Scheduling fails
  static Future<void> schedule({
    int id = 0,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    if (!_isInitialized) await initialize();

    final now = tz.TZDateTime.now(tz.local);

    // Create the scheduled time for today
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

    try {
      // First cancel any existing notifications
      await _notificationsPlugin.cancel(id);

      // Schedule the new notification
      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        _getNotificationDetails(),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Cancels all pending notifications.
  ///
  /// Throws an exception if:
  /// - Notification service is not initialized
  /// - Cancellation fails
  static Future<void> cancelAllNotifications() async {
    if (!_isInitialized) await initialize();
    await _notificationsPlugin.cancelAll();
  }
}
