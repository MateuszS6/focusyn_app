import 'package:flutter/material.dart';
import 'package:focusyn_app/util/my_app_bar.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(title: 'Privacy & Security'),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          "We respect your privacy.\n\n"
          "This app uses Firebase to store user authentication info securely.\n"
          "No sensitive personal data is collected.\n\n"
          "Make sure not to share your login credentials with others.",
        ),
      ),
    );
  }
}
