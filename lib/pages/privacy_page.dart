import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:focusyn_app/constants/theme_icons.dart';
import 'package:focusyn_app/services/cloud_sync_service.dart';
import 'package:focusyn_app/utils/my_app_bar.dart';
import 'package:focusyn_app/pages/login_page.dart';
import 'package:hive/hive.dart';
import 'package:focusyn_app/constants/keys.dart';

class PrivacyPage extends StatefulWidget {
  const PrivacyPage({super.key});

  @override
  State<PrivacyPage> createState() => _PrivacyPageState();
}

class _PrivacyPageState extends State<PrivacyPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: 'Privacy & Security',
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
            title: 'Data Privacy',
            children: [
              _buildDataCollectionTile(context),
              const SizedBox(height: 8),
              _buildDataProtectionTile(context),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            title: 'Contact',
            children: [_buildContactTile(context)],
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            title: 'Data Management',
            children: [
              _buildResetDataTile(context),
              const SizedBox(height: 8),
              _buildDeleteAccountTile(context),
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

  Widget _buildDataCollectionTile(BuildContext context) {
    return ListTile(
      leading: const Icon(ThemeIcons.dataIcon),
      title: const Text('Data Collection'),
      subtitle: const Text('What data we collect and why'),
      trailing: const Icon(ThemeIcons.openIcon, size: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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

  Widget _buildDataProtectionTile(BuildContext context) {
    return ListTile(
      leading: const Icon(ThemeIcons.shieldIcon),
      title: const Text('Data Protection'),
      subtitle: const Text('How we protect your information'),
      trailing: const Icon(ThemeIcons.openIcon, size: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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

  Widget _buildDeleteAccountTile(BuildContext context) {
    return ListTile(
      leading: const Icon(ThemeIcons.deleteIcon, color: Colors.red),
      title: const Text('Delete Account', style: TextStyle(color: Colors.red)),
      subtitle: const Text('Permanently delete your account and all data'),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      onTap: () {
        _deleteAccount();
      },
    );
  }

  Widget _buildResetDataTile(BuildContext context) {
    return ListTile(
      leading: const Icon(ThemeIcons.deleteIcon, color: Colors.red),
      title: const Text('Reset App Data', style: TextStyle(color: Colors.red)),
      subtitle: const Text('Clear all tasks, filters, and brain points'),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    onPressed: () {
                      Navigator.pop(context);
                      final scaffoldMessenger = ScaffoldMessenger.of(context);
                      CloudSyncService.clearLocalData(
                            Hive.box(Keys.taskBox),
                            Hive.box(Keys.filterBox),
                            Hive.box(Keys.brainBox),
                          )
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
                                content: Text('Failed to reset app data: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          });
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.red.shade50,
                      foregroundColor: Colors.red.shade700,
                    ),
                    child: const Text('Reset'),
                  ),
                ],
              ),
        );
      },
    );
  }

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
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.red.shade50,
                  foregroundColor: Colors.red.shade700,
                ),
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
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed:
                    () => Navigator.pop(context, passwordController.text),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.red.shade50,
                  foregroundColor: Colors.red.shade700,
                ),
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

  Widget _buildContactTile(BuildContext context) {
    return const ListTile(
      leading: Icon(ThemeIcons.mailIcon),
      title: Text('Questions?'),
      subtitle: Text('mstepien1104@gmail.com'),
    );
  }
}
