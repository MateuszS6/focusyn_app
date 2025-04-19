import 'package:flutter/material.dart';
import 'package:focusyn_app/constants/keys.dart';
import 'package:focusyn_app/constants/quotes.dart';
import 'package:focusyn_app/constants/theme_icons.dart';
import 'package:focusyn_app/services/notification_service.dart';
import 'package:focusyn_app/utils/my_app_bar.dart';
import 'package:hive/hive.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool _notificationsEnabled = false;
  TimeOfDay _notificationTime = const TimeOfDay(hour: 9, minute: 0);
  final _notificationBox = Hive.box(Keys.settingBox);

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    setState(() {
      _notificationsEnabled = _notificationBox.get(
        Keys.notificationsEnabled,
        defaultValue: false,
      );
      final hour = _notificationBox.get(Keys.notificationHour, defaultValue: 9);
      final minute = _notificationBox.get(
        Keys.notificationMinute,
        defaultValue: 0,
      );
      _notificationTime = TimeOfDay(hour: hour, minute: minute);
    });
  }

  Future<void> _saveSettings() async {
    await _notificationBox.put(
      Keys.notificationsEnabled,
      _notificationsEnabled,
    );
    await _notificationBox.put(Keys.notificationHour, _notificationTime.hour);
    await _notificationBox.put(
      Keys.notificationMinute,
      _notificationTime.minute,
    );
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
        title: 'Notifications',
        leading: IconButton(
          icon: const Icon(ThemeIcons.backIcon),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
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
                      trailing: const Icon(ThemeIcons.timeIcon),
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
                      Icon(ThemeIcons.infoIcon, color: Colors.blue[700]),
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
