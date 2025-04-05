import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:focusyn_app/data/keys.dart';
import 'package:focusyn_app/pages/privacy_page.dart';
import 'package:focusyn_app/pages/settings_page.dart';
import 'package:focusyn_app/util/my_app_bar.dart';
import '../pages/login_page.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final user = FirebaseAuth.instance.currentUser;

  Future<void> _updateDisplayName() async {
    final controller = TextEditingController(text: user?.displayName ?? "");
    final result = await showDialog<String>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Update Display Name"),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(labelText: "Display Name"),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, controller.text.trim()),
                child: const Text("Save"),
              ),
            ],
          ),
    );
    if (result != null && result.isNotEmpty) {
      await user?.updateDisplayName(result);
      await user?.reload();
      setState(() {});
    }
  }

  Future<void> _updatePassword() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Update Password"),
            content: TextField(
              controller: controller,
              obscureText: true,
              decoration: const InputDecoration(labelText: "New Password"),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, controller.text.trim()),
                child: const Text("Save"),
              ),
            ],
          ),
    );
    if (result != null && result.length >= 6) {
      await user?.updatePassword(result);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Password updated.")));
    } else if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Password must be at least 6 characters."),
        ),
      );
    }
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
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

  @override
  Widget build(BuildContext context) {
    final email = user?.email ?? "Unknown";
    final name = user?.displayName ?? "No name set";

    return Scaffold(
      appBar: MyAppBar(
        title: Keys.account,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        children: [
          const CircleAvatar(radius: 40, child: Icon(Icons.person, size: 40)),
          const SizedBox(height: 12),
          Center(
            child: Text(
              name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Center(child: Text(email)),
          const Divider(height: 32),

          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text("Edit Display Name"),
            onTap: _updateDisplayName,
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text("Change Password"),
            onTap: _updatePassword,
          ),
          const Divider(height: 32),

          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text("Settings"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.security),
            title: const Text("Privacy & Security"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PrivacyPage()),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.description),
            title: const Text("Terms & Conditions"),
            onTap:
                () => _showDialog(
                  "Terms & Conditions",
                  "Here you would show the terms of use for the app.",
                ),
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text("About"),
            onTap:
                () => _showDialog("About", "Focusyn App (Beta)\nVersion 1.0.0"),
          ),
          const Divider(height: 32),

          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Log Out"),
            onTap: _logout,
          ),
        ],
      ),
    );
  }
}
