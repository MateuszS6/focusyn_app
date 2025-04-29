import 'package:flutter/material.dart';
import 'package:focusyn_app/constants/keys.dart';
import 'package:focusyn_app/constants/quotes.dart';
import 'package:focusyn_app/constants/theme_icons.dart';
import 'package:focusyn_app/services/notification_service.dart';
import 'package:focusyn_app/utils/my_app_bar.dart';
import 'package:hive/hive.dart';

/// A page that provides user settings and preferences.
///
/// This page provides:
/// - Navigation bar label behavior settings
/// - Daily quote notification settings
/// - Notification time selection
/// - Settings persistence using Hive
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

/// Manages the state of the settings page, including:
/// - Loading and saving settings
/// - Notification management
/// - UI state for settings controls
class _SettingsPageState extends State<SettingsPage> {
  /// The current navigation bar label behavior setting
  String _navigationBarText =
      NavigationDestinationLabelBehavior.alwaysShow.name;

  /// Whether daily quote notifications are enabled
  bool _notificationsEnabled = false;

  /// The time at which daily quote notifications should be sent
  TimeOfDay _notificationTime = const TimeOfDay(hour: 9, minute: 0);

  /// Hive box for storing settings persistently
  final _settingBox = Hive.box(Keys.settingBox);

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  /// Loads settings from persistent storage and updates the UI state.
  ///
  /// This method is called during initialization to restore the user's
  /// previous settings.
  void _loadSettings() {
    setState(() {
      _navigationBarText = _settingBox.get(
        Keys.navigationBarTextBehaviour,
        defaultValue: NavigationDestinationLabelBehavior.alwaysShow.name,
      );
      _notificationsEnabled = _settingBox.get(
        Keys.notificationsEnabled,
        defaultValue: false,
      );
      final hour = _settingBox.get(Keys.notificationHour, defaultValue: 9);
      final minute = _settingBox.get(Keys.notificationMinute, defaultValue: 0);
      _notificationTime = TimeOfDay(hour: hour, minute: minute);
    });
  }

  /// Saves the current settings to persistent storage.
  ///
  /// This method is called whenever a setting is changed to ensure
  /// the user's preferences are preserved.
  Future<void> _saveSettings() async {
    await _settingBox.put(Keys.navigationBarTextBehaviour, _navigationBarText);
    await _settingBox.put(Keys.notificationsEnabled, _notificationsEnabled);
    await _settingBox.put(Keys.notificationHour, _notificationTime.hour);
    await _settingBox.put(Keys.notificationMinute, _notificationTime.minute);
  }

  /// Shows a time picker dialog to select the notification time.
  ///
  /// Updates the notification time if a new time is selected and
  /// saves the setting.
  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _notificationTime,
    );

    if (picked != null && picked != _notificationTime) {
      setState(() {
        _notificationTime = picked;
      });
      await _saveSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: MyAppBar(
        title: Keys.settings,
        leading: IconButton(
          icon: const Icon(ThemeIcons.back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // General Settings Section
            Text(
              'General',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(13),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  ListTile(
                    title: const Text(
                      'Navigation Bar Labels',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: DropdownButtonFormField<String>(
                      value: _navigationBarText,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(16)),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      items: [
                        DropdownMenuItem(
                          value:
                              NavigationDestinationLabelBehavior
                                  .alwaysShow
                                  .name,
                          child: const Text('Always show labels'),
                        ),
                        DropdownMenuItem(
                          value:
                              NavigationDestinationLabelBehavior
                                  .onlyShowSelected
                                  .name,
                          child: const Text('Show label when selected'),
                        ),
                        DropdownMenuItem(
                          value:
                              NavigationDestinationLabelBehavior
                                  .alwaysHide
                                  .name,
                          child: const Text('Always hide labels'),
                        ),
                      ],
                      onChanged: (String? value) async {
                        if (value != null) {
                          setState(() => _navigationBarText = value);
                          await _saveSettings();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Notifications Section
            Text(
              'Notifications',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(13),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text(
                      'Daily Quote Notifications',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      _notificationsEnabled
                          ? 'You will receive a daily motivational quote at ${_notificationTime.format(context)}'
                          : 'Notifications are disabled',
                    ),
                    value: _notificationsEnabled,
                    onChanged: (bool value) async {
                      setState(() {
                        _notificationsEnabled = value;
                      });

                      // Save settings first
                      await _saveSettings();

                      // Then handle notifications
                      if (_notificationsEnabled) {
                        // Cancel any existing notifications first
                        await NotificationService.cancelAllNotifications();
                        // Schedule the new notification
                        await NotificationService.schedule(
                          title: 'Daily Quote',
                          body: Quotes.getRandomQuote().text,
                          hour: _notificationTime.hour,
                          minute: _notificationTime.minute,
                        );
                        // Show a test notification immediately
                        await NotificationService.show(
                          title: 'Notifications Enabled',
                          body:
                              'You will receive daily quotes at ${_notificationTime.hour}:${_notificationTime.minute}',
                        );
                      } else {
                        await NotificationService.cancelAllNotifications();
                      }
                    },
                    activeColor: Colors.blue,
                  ),
                  if (_notificationsEnabled)
                    ListTile(
                      title: const Text('Notification Time'),
                      subtitle: Text(_notificationTime.format(context)),
                      trailing: const Icon(ThemeIcons.time),
                      onTap: _selectTime,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: InkWell(
                onTap: () async {
                  final scaffoldMessenger = ScaffoldMessenger.of(context);
                  try {
                    // Ensure notification service is initialized
                    if (!NotificationService.isInitialized) {
                      await NotificationService.initialize();
                    }

                    // Show a test notification
                    await NotificationService.show(
                      title: 'Test Notification',
                      body:
                          'This is a test notification to demonstrate how daily quotes will appear.',
                    );
                  } catch (e) {
                    if (mounted) {
                      scaffoldMessenger.showSnackBar(
                        const SnackBar(
                          content: Text('Failed to show test notification'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                borderRadius: BorderRadius.circular(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(ThemeIcons.info, color: Colors.blue[700]),
                        const SizedBox(width: 8),
                        Text(
                          'About Notifications',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Daily quote notifications will help you stay motivated and focused throughout your day. You can choose when to receive these notifications.',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap here to see a test notification',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue[700],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
