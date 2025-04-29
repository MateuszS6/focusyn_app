import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:focusyn_app/constants/theme_icons.dart';
import 'package:focusyn_app/services/cloud_sync_service.dart';
import 'package:focusyn_app/utils/my_app_bar.dart';
import 'package:focusyn_app/pages/login_page.dart';
import 'package:hive/hive.dart';
import 'package:focusyn_app/constants/keys.dart';

/// A page that provides privacy and security information and controls.
///
/// This page provides:
/// - Data collection and protection information
/// - Contact information
/// - Account management options
/// - Data reset and deletion controls
class PrivacyPage extends StatefulWidget {
  const PrivacyPage({super.key});

  @override
  State<PrivacyPage> createState() => _PrivacyPageState();
}

/// Manages the state of the privacy page, including:
/// - Privacy information display
/// - Account management actions
/// - Data protection controls
class _PrivacyPageState extends State<PrivacyPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: Keys.privacy,
        leading: IconButton(
          icon: const Icon(ThemeIcons.back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Data Privacy Section
          Text(
            'Privacy & Security',
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
                _buildDataCollectionTile(context),
                const Divider(height: 1, color: Color(0xFFE0E0E0)),
                _buildDataProtectionTile(context),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Contact Section
          Text(
            'Contact',
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
            child: _buildContactTile(context),
          ),
          const SizedBox(height: 24),

          // Danger Zone Section
          Text(
            'Danger Zone',
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
                _buildResetDataTile(context),
                const Divider(height: 1, color: Color(0xFFE0E0E0)),
                _buildDeleteAccountTile(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a tile showing data collection information
  Widget _buildDataCollectionTile(BuildContext context) {
    return ListTile(
      leading: const Icon(ThemeIcons.data),
      title: const Text('Data Collection'),
      subtitle: const Text('What data we collect and why'),
      trailing: const Icon(ThemeIcons.open, size: 20),
      onTap: () {
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Data Collection'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'We collect minimal data necessary to provide our services:',
                    ),
                    SizedBox(height: 16),
                    Text('• Task information (title, date, time, duration)'),
                    Text('• User preferences and settings'),
                    Text('• App usage statistics (anonymized)'),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              ),
        );
      },
    );
  }

  /// Builds a tile showing data protection information
  Widget _buildDataProtectionTile(BuildContext context) {
    return ListTile(
      leading: const Icon(ThemeIcons.privacy),
      title: const Text('Data Protection'),
      subtitle: const Text('How we protect your information'),
      trailing: const Icon(ThemeIcons.open, size: 20),
      onTap: () {
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Data Protection'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Your data is protected with:'),
                    SizedBox(height: 16),
                    Text('• Local device storage with encryption'),
                    Text('• Optional encrypted cloud backup'),
                    Text('• No third-party data sharing'),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              ),
        );
      },
    );
  }

  /// Builds a tile for deleting the user's account
  Widget _buildDeleteAccountTile(BuildContext context) {
    return ListTile(
      leading: const Icon(ThemeIcons.delete, color: Colors.red),
      title: const Text('Delete Account', style: TextStyle(color: Colors.red)),
      subtitle: const Text('Permanently delete your account and all data'),
      onTap: () {
        _deleteAccount();
      },
    );
  }

  /// Builds a tile for resetting app data
  Widget _buildResetDataTile(BuildContext context) {
    return ListTile(
      leading: const Icon(ThemeIcons.delete, color: Colors.red),
      title: const Text('Reset App Data', style: TextStyle(color: Colors.red)),
      subtitle: const Text('Clear all tasks, filters, and brain points'),
      onTap: () {
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Reset App Data'),
                content: const Text(
                  'Are you sure you want to reset all app data? This will clear all your tasks, filters, and brain points. This action cannot be undone.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Icon(ThemeIcons.cancel),
                  ),
                  FilledButton(
                    onPressed: () {
                      Navigator.pop(context);
                      final scaffoldMessenger = ScaffoldMessenger.of(context);
                      // Clear only app data in Firestore (tasks, filters, brain points)
                      CloudSyncService.clearAppData()
                          .then((_) {
                            // Then clear local data
                            return CloudSyncService.clearLocalData(
                              Hive.box<List>(Keys.taskBox),
                              Hive.box(Keys.filterBox),
                              Hive.box(Keys.brainBox),
                              Hive.box(Keys.historyBox),
                              Hive.box(Keys.chatBox),
                            );
                          })
                          .then((_) {
                            if (!mounted) return;
                            scaffoldMessenger.showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'App data has been reset successfully',
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                          })
                          .catchError((e) {
                            if (!mounted) return;
                            scaffoldMessenger.showSnackBar(
                              SnackBar(
                                content: Text('Error resetting data: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          });
                    },
                    style: FilledButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text('Reset'),
                  ),
                ],
              ),
        );
      },
    );
  }

  /// Builds a tile showing contact information
  Widget _buildContactTile(BuildContext context) {
    return ListTile(
      leading: const Icon(ThemeIcons.email),
      title: const Text('Contact Us'),
      subtitle: const Text('Get in touch with our support team'),
      trailing: const Icon(ThemeIcons.open, size: 20),
      onTap: () {
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Contact Us'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Need help or have questions?'),
                    SizedBox(height: 16),
                    Text('Email: mstepien1104@gmail.com'),
                    Text('Hours: Mon-Fri, 9am-5pm GMT'),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              ),
        );
      },
    );
  }

  /// Deletes the user's account and all associated data
  Future<void> _deleteAccount() async {
    // First confirm the user wants to delete their account
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Account'),
            content: const Text(
              'Are you sure you want to delete your account? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Icon(ThemeIcons.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirmed != true || !mounted) return;

    // Get current user's email
    final user = FirebaseAuth.instance.currentUser;
    final userEmail = user?.email;
    if (user == null || userEmail == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No user found')));
      return;
    }

    // Ask for password to re-authenticate
    final passwordController = TextEditingController();
    final password = await showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirm Password'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Please enter your password to confirm account deletion.',
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Icon(ThemeIcons.cancel),
              ),
              FilledButton(
                onPressed:
                    () => Navigator.pop(context, passwordController.text),
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Confirm'),
              ),
            ],
          ),
    );

    if (password == null || !mounted) return;

    try {
      // Re-authenticate user
      final credential = EmailAuthProvider.credential(
        email: userEmail,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);

      // Clear local data first
      await CloudSyncService.clearLocalData(
        Hive.box<List>(Keys.taskBox),
        Hive.box(Keys.filterBox),
        Hive.box(Keys.brainBox),
        Hive.box(Keys.historyBox),
        Hive.box(Keys.chatBox),
      );

      // Delete user data from Firestore
      await CloudSyncService.deleteUserData();

      // Delete Firebase Auth account
      await user.delete();

      if (!mounted) return;
      // Navigate to login page
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.code == 'wrong-password'
                ? 'Incorrect password'
                : 'Failed to delete account: ${e.message}',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete account: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
