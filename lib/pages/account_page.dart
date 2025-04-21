import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:focusyn_app/constants/keys.dart';
import 'package:focusyn_app/constants/theme_icons.dart';
import 'package:focusyn_app/pages/settings_page.dart';
import 'package:focusyn_app/pages/privacy_page.dart';
import 'package:focusyn_app/utils/my_app_bar.dart';
import '../pages/login_page.dart';
import 'package:hive/hive.dart';
import 'package:focusyn_app/services/cloud_sync_service.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  Future<void> _updateDisplayName() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final controller = TextEditingController(
      text: currentUser?.displayName ?? "",
    );
    final result = await showDialog<String>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Update Display Name"),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: "Display Name",
                border: OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Icon(ThemeIcons.cancel),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, controller.text.trim()),
                child: const Icon(ThemeIcons.done),
              ),
            ],
          ),
    );

    if (result != null && result.isNotEmpty) {
      try {
        // Update Auth display name
        await currentUser?.updateDisplayName(result);
        // Update Firestore profile
        await CloudSyncService.updateUserProfile(result);
        await currentUser?.reload();

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Display name updated to "$result"'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
        setState(() {}); // This will trigger a rebuild with the new data
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update display name: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  Future<void> _updatePassword() async {
    if (!mounted) return;

    // First get the current password for reauthentication
    final currentPasswordController = TextEditingController();
    final currentPasswordResult = await showDialog<String>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Current Password"),
            content: TextField(
              controller: currentPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Enter current password",
                border: OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Icon(ThemeIcons.cancel),
              ),
              ElevatedButton(
                onPressed:
                    () => Navigator.pop(
                      context,
                      currentPasswordController.text.trim(),
                    ),
                child: const Icon(ThemeIcons.next),
              ),
            ],
          ),
    );

    if (currentPasswordResult == null || !mounted) return;

    try {
      // Reauthenticate user
      final credentials = EmailAuthProvider.credential(
        email: FirebaseAuth.instance.currentUser?.email ?? '',
        password: currentPasswordResult,
      );
      await FirebaseAuth.instance.currentUser?.reauthenticateWithCredential(
        credentials,
      );

      if (!mounted) return;

      // Now prompt for new password
      final newPasswordController = TextEditingController();
      final newPassword = await showDialog<String>(
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text("New Password"),
              content: TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Enter new password",
                  hintText: "At least 6 characters",
                  border: OutlineInputBorder(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Icon(ThemeIcons.cancel),
                ),
                ElevatedButton(
                  onPressed:
                      () => Navigator.pop(
                        context,
                        newPasswordController.text.trim(),
                      ),
                  child: const Icon(ThemeIcons.done),
                ),
              ],
            ),
      );

      if (!mounted) return;

      if (newPassword != null && newPassword.length >= 6) {
        await FirebaseAuth.instance.currentUser?.updatePassword(newPassword);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Password updated successfully.")),
        );
      } else if (newPassword != null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Password must be at least 6 characters."),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "Failed to update password.")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("An error occurred while updating password."),
        ),
      );
    }
  }

  Future<void> _updateEmail() async {
    if (!mounted) return;

    // First get the current password for reauthentication
    final currentPasswordController = TextEditingController();
    final currentPasswordResult = await showDialog<String>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Current Password"),
            content: TextField(
              controller: currentPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Enter current password",
                border: OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Icon(ThemeIcons.cancel),
              ),
              ElevatedButton(
                onPressed:
                    () => Navigator.pop(
                      context,
                      currentPasswordController.text.trim(),
                    ),
                child: const Icon(ThemeIcons.next),
              ),
            ],
          ),
    );

    if (currentPasswordResult == null || !mounted) return;

    try {
      // Reauthenticate user
      final credentials = EmailAuthProvider.credential(
        email: FirebaseAuth.instance.currentUser?.email ?? '',
        password: currentPasswordResult,
      );
      await FirebaseAuth.instance.currentUser?.reauthenticateWithCredential(
        credentials,
      );

      if (!mounted) return;

      // Now prompt for new email
      final newEmailController = TextEditingController();
      final newEmail = await showDialog<String>(
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text("New Email"),
              content: TextField(
                controller: newEmailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: "Enter new email address",
                  border: OutlineInputBorder(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Icon(ThemeIcons.cancel),
                ),
                ElevatedButton(
                  onPressed:
                      () => Navigator.pop(
                        context,
                        newEmailController.text.trim(),
                      ),
                  child: const Icon(ThemeIcons.done),
                ),
              ],
            ),
      );

      if (!mounted) return;

      if (newEmail != null && newEmail.isNotEmpty) {
        // Update email in Firebase Auth with verification
        await FirebaseAuth.instance.currentUser?.verifyBeforeUpdateEmail(
          newEmail,
        );

        // Update email in Firestore profile
        await CloudSyncService.updateUserProfile(
          FirebaseAuth.instance.currentUser?.displayName ?? '',
          newEmail: newEmail,
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Verification email sent to $newEmail. Please check your inbox to complete the change.",
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
        setState(() {}); // Refresh the UI
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? "Failed to update email."),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("An error occurred while updating email: $e"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  Future<void> _logout() async {
    try {
      // Clear local data
      await CloudSyncService.clearLocalData(
        Hive.box<List>(Keys.taskBox),
        Hive.box(Keys.filterBox),
        Hive.box(Keys.brainBox),
        Hive.box(Keys.historyBox),
      );

      // Sign out from Firebase
      await FirebaseAuth.instance.signOut();

      // Navigate to login page
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error logging out: $e')));
      }
    }
  }

  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Close"),
              ),
            ],
          ),
    );
  }

  static const settingsIcon = ThemeIcons.settings;
  static const userIcon = ThemeIcons.user;
  static const emailIcon = ThemeIcons.email;
  static const lockIcon = ThemeIcons.lock;
  static const securityIcon = Icons.shield_rounded;
  static const termsIcon = ThemeIcons.terms;
  static const infoIcon = ThemeIcons.info;
  static const logoutIcon = ThemeIcons.logout;

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: MyAppBar(
        title: Keys.account,
        leading: IconButton(
          icon: const Icon(ThemeIcons.back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(settingsIcon),
            tooltip: Keys.settings,
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Profile Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.orange.shade50, Colors.white],
                ),
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
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.orange.shade100,
                    child: Text(
                      currentUser?.displayName?.substring(0, 1) ?? 'M',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    currentUser?.displayName ?? 'No name set',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    currentUser?.email ?? 'Unknown',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Settings List
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.grey.shade50, Colors.white],
                ),
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
                  _buildSettingItem(
                    context,
                    icon: userIcon,
                    label: 'Edit Display Name',
                    onTap: _updateDisplayName,
                  ),
                  _buildDivider(),
                  _buildSettingItem(
                    context,
                    icon: emailIcon,
                    label: 'Change Email',
                    onTap: _updateEmail,
                  ),
                  _buildDivider(),
                  _buildSettingItem(
                    context,
                    icon: lockIcon,
                    label: 'Change Password',
                    onTap: _updatePassword,
                  ),
                  _buildDivider(),
                  _buildSettingItem(
                    context,
                    icon: securityIcon,
                    label: Keys.privacy,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PrivacyPage()),
                      );
                    },
                  ),
                  _buildDivider(),
                  _buildSettingItem(
                    context,
                    icon: termsIcon,
                    label: 'Terms of Use',
                    onTap:
                        () => _showDialog(
                          "Terms of Use",
                          "By using Focusyn, you agree to:\n\n"
                              "• Use the app for personal task management\n"
                              "• Keep your account credentials secure\n"
                              "• Not misuse or exploit the app\n\n"
                              "Your data is stored securely and you retain full control over it.\n\n"
                              "Last updated: March 2024",
                        ),
                  ),
                  _buildDivider(),
                  _buildSettingItem(
                    context,
                    icon: infoIcon,
                    label: 'About',
                    onTap:
                        () => _showDialog(
                          "About",
                          "Focusyn App (Beta)\nVersion 1.0.0",
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Logout Button
            FilledButton.tonal(
              onPressed: _logout,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red.shade50,
                foregroundColor: Colors.red.shade700,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(logoutIcon),
                  const SizedBox(width: 8),
                  Text(
                    'Log Out',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.red.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(icon, color: Colors.grey.shade700),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              Icon(ThemeIcons.open, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey.shade200,
      indent: 48,
    );
  }
}
