import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static bool _isInitialized = false;

  static bool get isInitialized => _isInitialized;

  // Initialize the notification service
  static Future<void> initialize() async {
    if (_isInitialized) return; // Already initialized

    // Initializing notification service...

    // Initialize timezone
    tz.initializeTimeZones();
    String currentTimeZone = 'Europe/London';
    try {
      currentTimeZone = await FlutterTimezone.getLocalTimezone();
    } catch (e) {
      throw Exception('Error getting local timezone, defaulting to London: $e');
    }
    tz.setLocalLocation(tz.getLocation(currentTimeZone));

    // Initialize the Android settings
    const initializationSettingsAndroid = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    // Initialize the iOS settings
    const initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    // Initialize the notification service
    final bool? result = await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Notification clicked: ${response.payload}
      },
    );
    // Notification initialization result

    // Request permissions
    final bool? permissionResult =
        await _notificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.requestNotificationsPermission();
    // Android permission result

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
    // Notification service initialized successfully
  }

  // Get notification details
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

  // Show a notification
  static Future<void> show({int id = 0, String? title, String? body}) async {
    if (!_isInitialized) await initialize();

    // Showing notification
    return _notificationsPlugin.show(
      id,
      title,
      body,
      _getNotificationDetails(),
    );
  }

  // Schedule a notification
  static Future<void> schedule({
    int id = 0,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    if (!_isInitialized) await initialize();

    // Scheduling notification
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
      // Time already passed today, scheduling for tomorrow
    }

    // Scheduling notification
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
        // payload: 'daily_quote',
      );
      // Notification scheduled successfully

      // Verify the scheduled notification
      final pendingNotifications =
          await _notificationsPlugin.pendingNotificationRequests();
      // Pending notifications
      for (var notification in pendingNotifications) {
        // Pending notification
      }
    } catch (e) {
      // Error scheduling notification
      rethrow;
    }
  }

  // Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    if (!_isInitialized) await initialize();
    // Cancelling all notifications
    await _notificationsPlugin.cancelAll();
  }
}
