import 'package:flutter/material.dart';
import 'package:focusyn_app/constants/keys.dart';
import 'package:focusyn_app/constants/theme_icons.dart';
import '../utils/my_app_bar.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

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
            title: 'Backup',
            children: [
              _buildBackupButton(context),
              const SizedBox(height: 8),
              _buildRestoreButton(context),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            title: 'Preferences',
            children: [
              _buildDailyGoalSelector(context),
              const SizedBox(height: 8),
              _buildWeekStartSelector(context),
            ],
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
        value: ThemeMode.system,
        items: const [
          DropdownMenuItem(
            value: ThemeMode.system,
            child: Text('System Default'),
          ),
          DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
          DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
        ],
        onChanged: (ThemeMode? newValue) {
          // TODO: Implement theme change
        },
      ),
    );
  }

  Widget _buildBackupButton(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.cloud_upload_rounded),
      title: const Text('Backup to Cloud'),
      onTap: () {
        // TODO: Implement backup
      },
    );
  }

  Widget _buildRestoreButton(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.cloud_download_rounded),
      title: const Text('Restore from Cloud'),
      onTap: () {
        // TODO: Implement restore
      },
    );
  }

  Widget _buildDailyGoalSelector(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.flag_rounded),
      title: const Text('Daily Focus Goal'),
      trailing: DropdownButton<int>(
        value: 3,
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
          // TODO: Implement goal change
        },
      ),
    );
  }

  Widget _buildWeekStartSelector(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.calendar_today_rounded),
      title: const Text('Start Week On'),
      trailing: DropdownButton<String>(
        value: 'Monday',
        items: const [
          DropdownMenuItem(value: 'Monday', child: Text('Monday')),
          DropdownMenuItem(value: 'Sunday', child: Text('Sunday')),
        ],
        onChanged: (String? newValue) {
          // TODO: Implement week start change
        },
      ),
    );
  }
}
