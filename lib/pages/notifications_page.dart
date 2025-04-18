import 'package:flutter/material.dart';
import 'package:focusyn_app/constants/keys.dart';
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
        'notifications',
        defaultValue: false,
      );
      final hour = _notificationBox.get('notificationHour', defaultValue: 9);
      final minute = _notificationBox.get(
        'notificationMinute',
        defaultValue: 0,
      );
      _notificationTime = TimeOfDay(hour: hour, minute: minute);
    });
  }

  Future<void> _saveSettings() async {
    await _notificationBox.put('notifications', _notificationsEnabled);
    await _notificationBox.put('notificationHour', _notificationTime.hour);
    await _notificationBox.put('notificationMinute', _notificationTime.minute);

    // Schedule or cancel notifications based on settings
    await NotificationService.scheduleQuoteNotification(
      hour: _notificationTime.hour,
      minute: _notificationTime.minute,
      isEnabled: _notificationsEnabled,
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
                    onChanged: (bool value) {
                      setState(() {
                        _notificationsEnabled = value;
                      });
                      _saveSettings();
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
