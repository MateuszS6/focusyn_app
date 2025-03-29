import 'package:flutter/material.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Account"),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        children: [
          CircleAvatar(radius: 40, child: Icon(Icons.person, size: 40)),
          SizedBox(height: 12),
          Center(
            child: Text(
              "Mateusz",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Divider(height: 32),

          ListTile(
            leading: Icon(Icons.settings_rounded),
            title: Text("Settings"),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.lock_rounded),
            title: Text("Privacy & Security"),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.description_rounded),
            title: Text("Terms & Conditions"),
            onTap: () {
              showDialog(
                context: context,
                builder:
                    (_) => AlertDialog(
                      title: Text("Terms & Conditions"),
                      content: Text(
                        "Here you would show the terms of use for the app.",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text("Close"),
                        ),
                      ],
                    ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.info_rounded),
            title: Text("About"),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.logout_rounded),
            title: Text("Log Out"),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
