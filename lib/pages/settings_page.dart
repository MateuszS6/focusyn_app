import 'package:flutter/material.dart';
import 'package:focusyn_app/util/my_app_bar.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(title: 'Settings'),
      body: const Center(child: Text("Settings page content coming soon")),
    );
  }
}
