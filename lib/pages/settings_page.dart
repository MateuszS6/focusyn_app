import 'package:flutter/material.dart';
import 'package:focusyn_app/constants/keys.dart';
import 'package:focusyn_app/constants/quotes.dart';
import 'package:focusyn_app/constants/theme_icons.dart';
import 'package:focusyn_app/services/notification_service.dart';
import 'package:focusyn_app/utils/my_app_bar.dart';
import 'package:hive/hive.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _navigationBarText =
      NavigationDestinationLabelBehavior.alwaysShow.name;
  bool _notificationsEnabled = false;
  TimeOfDay _notificationTime = const TimeOfDay(hour: 9, minute: 0);
  final _settingBox = Hive.box(Keys.settingBox);

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

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

  Future<void> _saveSettings() async {
    await _settingBox.put(Keys.navigationBarTextBehaviour, _navigationBarText);
    await _settingBox.put(Keys.notificationsEnabled, _notificationsEnabled);
    await _settingBox.put(Keys.notificationHour, _notificationTime.hour);
    await _settingBox.put(Keys.notificationMinute, _notificationTime.minute);
  }

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
        title: 'Settings',
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
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'You will receive a daily motivational quote at your selected time. '
                    'These notifications are designed to help you stay motivated and focused throughout your day.',
                    style: TextStyle(color: Colors.blue[900]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
