import 'package:flutter/material.dart';
import 'package:focusyn_app/constants/keys.dart';
import 'package:hive/hive.dart';

/// Service class for managing app settings
/// This service provides:
/// - Loading and saving settings
/// - Default values management
/// - Settings state management
class SettingService {
  static final _settingBox = Hive.box(Keys.settingBox);

  /// Loads navigation bar text behavior setting
  static String getNavigationBarText() {
    return _settingBox.get(
      Keys.navigationBarTextBehaviour,
      defaultValue: NavigationDestinationLabelBehavior.alwaysShow.name,
    );
  }

  /// Loads notifications enabled setting
  static bool getNotificationsEnabled() {
    return _settingBox.get(
      Keys.notificationsEnabled,
      defaultValue: false,
    );
  }

  /// Loads notification time setting
  static TimeOfDay getNotificationTime() {
    final hour = _settingBox.get(Keys.notificationHour, defaultValue: 9);
    final minute = _settingBox.get(Keys.notificationMinute, defaultValue: 0);
    return TimeOfDay(hour: hour, minute: minute);
  }

  /// Saves navigation bar text behavior setting
  static Future<void> setNavigationBarText(String value) async {
    await _settingBox.put(Keys.navigationBarTextBehaviour, value);
  }

  /// Saves notifications enabled setting
  static Future<void> setNotificationsEnabled(bool value) async {
    await _settingBox.put(Keys.notificationsEnabled, value);
  }

  /// Saves notification time setting
  static Future<void> setNotificationTime(TimeOfDay time) async {
    await _settingBox.put(Keys.notificationHour, time.hour);
    await _settingBox.put(Keys.notificationMinute, time.minute);
  }

  /// Gets all settings as a map for cloud sync
  static Map<String, dynamic> getAllSettings() {
    return {
      Keys.navigationBarTextBehaviour: getNavigationBarText(),
      Keys.notificationsEnabled: getNotificationsEnabled(),
      Keys.notificationHour: getNotificationTime().hour,
      Keys.notificationMinute: getNotificationTime().minute,
    };
  }

  /// Updates all settings from a map (used for cloud sync)
  static Future<void> updateAllSettings(Map<String, dynamic> settings) async {
    await setNavigationBarText(settings[Keys.navigationBarTextBehaviour] ?? NavigationDestinationLabelBehavior.alwaysShow.name);
    await setNotificationsEnabled(settings[Keys.notificationsEnabled] ?? false);
    await setNotificationTime(
      TimeOfDay(
        hour: settings[Keys.notificationHour] ?? 9,
        minute: settings[Keys.notificationMinute] ?? 0,
      ),
    );
  }
}