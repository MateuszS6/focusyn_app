import 'package:flutter/material.dart';
import 'package:focusyn_app/constants/keys.dart';
import 'package:focusyn_app/services/cloud_service.dart';
import 'package:hive/hive.dart';

/// Service class for managing app settings
/// This service provides:
/// - Loading and saving settings
/// - Default values management
/// - Settings state management
class SettingService {
  static final _box = Hive.box(Keys.settingBox);

  /// Loads onboarding completion status
  static bool isOnboardingDone() {
    return _box.get(Keys.onboardingDone, defaultValue: false);
  }

  /// Loads navigation bar text behavior setting
  static String getNavBarText() {
    return _box.get(
      Keys.navBarText,
      defaultValue: NavigationDestinationLabelBehavior.alwaysShow.name,
    );
  }

  /// Loads notifications enabled setting
  static bool isNotisEnabled() {
    return _box.get(Keys.notisEnabled, defaultValue: false);
  }

  /// Loads notification time setting
  static TimeOfDay getNotificationTime() {
    final hour = _box.get(Keys.notiHour, defaultValue: 9);
    final minute = _box.get(Keys.notiMinute, defaultValue: 0);
    return TimeOfDay(hour: hour, minute: minute);
  }

  /// Saves onboarding completion status
  static Future<void> setOnboardingDone(bool value) async {
    await _box.put(Keys.onboardingDone, value);
    CloudService.uploadSettings();
  }

  /// Saves navigation bar text behavior setting
  static Future<void> setNavBarText(String value) async {
    await _box.put(Keys.navBarText, value);
  }

  /// Saves notifications enabled setting
  static Future<void> setNotisEnabled(bool value) async {
    await _box.put(Keys.notisEnabled, value);
  }

  /// Saves notification time setting
  static Future<void> setNotiTime(TimeOfDay time) async {
    await _box.put(Keys.notiHour, time.hour);
    await _box.put(Keys.notiMinute, time.minute);
  }

  /// Gets all settings as a map for cloud sync
  static Map<String, dynamic> getAllSettings() {
    return {
      Keys.onboardingDone: isOnboardingDone(),
      Keys.navBarText: getNavBarText(),
      Keys.notisEnabled: isNotisEnabled(),
      Keys.notiHour: getNotificationTime().hour,
      Keys.notiMinute: getNotificationTime().minute,
    };
  }

  /// Updates all settings from a map (used for cloud sync)
  static Future<void> updateAllSettings(Map<String, dynamic> settings) async {
    await setOnboardingDone(settings[Keys.onboardingDone] ?? false);
    await setNavBarText(
      settings[Keys.navBarText] ??
          NavigationDestinationLabelBehavior.alwaysShow.name,
    );
    await setNotisEnabled(settings[Keys.notisEnabled] ?? false);
    await setNotiTime(
      TimeOfDay(
        hour: settings[Keys.notiHour] ?? 9,
        minute: settings[Keys.notiMinute] ?? 0,
      ),
    );
  }
}
