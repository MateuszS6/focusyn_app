import 'package:flutter/material.dart';
import 'package:focusyn_app/constants/keys.dart';
import 'package:focusyn_app/constants/theme_icons.dart';
import 'package:focusyn_app/services/cloud_sync_service.dart';
import 'package:hive/hive.dart';
import '../utils/my_app_bar.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Settings keys
  static const String _themeKey = 'theme_mode';
  static const String _dailyGoalKey = 'daily_focus_goal';
  static const String _weekStartKey = 'week_start_day';
  static const String _notificationsKey = 'notifications_enabled';

  // Default values
  ThemeMode _themeMode = ThemeMode.system;
  int _dailyGoal = 3;
  String _weekStart = 'Monday';
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settingsBox = Hive.box(Keys.settingsBox);

    setState(() {
      _themeMode =
          ThemeMode.values[settingsBox.get(_themeKey, defaultValue: 0)];
      _dailyGoal = settingsBox.get(_dailyGoalKey, defaultValue: 3);
      _weekStart = settingsBox.get(_weekStartKey, defaultValue: 'Monday');
      _notificationsEnabled = settingsBox.get(
        _notificationsKey,
        defaultValue: true,
      );
    });
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    final settingsBox = Hive.box(Keys.settingsBox);
    await settingsBox.put(key, value);

    // Sync to cloud if needed
    try {
      await CloudSyncService.uploadSettings(settingsBox);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to sync settings: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: Keys.settings,
        leading: IconButton(
          icon: const Icon(ThemeIcons.backIcon),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildSection(
            context,
            title: 'Appearance',
            children: [_buildThemeSelector(context)],
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            title: 'Focus',
            children: [
              _buildDailyGoalSelector(context),
              const SizedBox(height: 8),
              _buildWeekStartSelector(context),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            title: 'Notifications',
            children: [_buildNotificationToggle(context)],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildThemeSelector(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.palette_rounded),
      title: const Text('Theme'),
      trailing: DropdownButton<ThemeMode>(
        value: _themeMode,
        items: const [
          DropdownMenuItem(
            value: ThemeMode.system,
            child: Text('System Default'),
          ),
          DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
          DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
        ],
        onChanged: (ThemeMode? newValue) {
          if (newValue != null) {
            setState(() {
              _themeMode = newValue;
            });
            _saveSetting(_themeKey, newValue.index);
            // Apply theme change
            // This would typically be handled by a theme provider in a real app
            // For now, we'll just show a message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Theme changed to ${newValue.toString().split('.').last}',
                ),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        },
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  Widget _buildDailyGoalSelector(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.flag_rounded),
      title: const Text('Daily Focus Goal'),
      trailing: DropdownButton<int>(
        value: _dailyGoal,
        items:
            List.generate(5, (index) => index + 1)
                .map(
                  (value) => DropdownMenuItem(
                    value: value,
                    child: Text('$value Flows'),
                  ),
                )
                .toList(),
        onChanged: (int? newValue) {
          if (newValue != null) {
            setState(() {
              _dailyGoal = newValue;
            });
            _saveSetting(_dailyGoalKey, newValue);
          }
        },
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  Widget _buildWeekStartSelector(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.calendar_today_rounded),
      title: const Text('Start Week On'),
      trailing: DropdownButton<String>(
        value: _weekStart,
        items: const [
          DropdownMenuItem(value: 'Monday', child: Text('Monday')),
          DropdownMenuItem(value: 'Sunday', child: Text('Sunday')),
        ],
        onChanged: (String? newValue) {
          if (newValue != null) {
            setState(() {
              _weekStart = newValue;
            });
            _saveSetting(_weekStartKey, newValue);
          }
        },
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  Widget _buildNotificationToggle(BuildContext context) {
    return SwitchListTile(
      secondary: const Icon(Icons.notifications_rounded),
      title: const Text('Enable Notifications'),
      subtitle: const Text('Get reminders for your tasks and flows'),
      value: _notificationsEnabled,
      onChanged: (bool value) {
        setState(() {
          _notificationsEnabled = value;
        });
        _saveSetting(_notificationsKey, value);
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }
}
