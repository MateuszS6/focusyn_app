import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../util/my_app_bar.dart';
import '../pages/login_page.dart';

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
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
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
            children: [_buildDeleteAccountTile(context)],
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
      leading: const Icon(Icons.data_usage_rounded),
      title: const Text('Data Collection'),
      subtitle: const Text('What data we collect and why'),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 20),
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
      leading: const Icon(Icons.shield_rounded),
      title: const Text('Data Protection'),
      subtitle: const Text('How we protect your information'),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 20),
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
      leading: const Icon(Icons.delete_forever_rounded, color: Colors.red),
      title: const Text('Delete Account', style: TextStyle(color: Colors.red)),
      subtitle: const Text('Permanently delete your account and all data'),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      onTap: () {
        final navigator = Navigator.of(context);
        final scaffoldMessenger = ScaffoldMessenger.of(context);

        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Delete Account'),
                content: const Text(
                  'This will permanently delete your account and all associated data. This action cannot be undone.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      try {
                        await FirebaseAuth.instance.currentUser?.delete();
                        if (!mounted) return;
                        navigator.pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                          (route) => false,
                        );
                      } on FirebaseAuthException catch (e) {
                        if (!mounted) return;
                        scaffoldMessenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              e.message ?? 'Failed to delete account',
                            ),
                          ),
                        );
                      }
                    },
                    child: const Text(
                      'Delete',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
        );
      },
    );
  }

  Widget _buildContactTile(BuildContext context) {
    return const ListTile(
      leading: Icon(Icons.mail_rounded),
      title: Text('Questions?'),
      subtitle: Text('mstepien1104@gmail.com'),
    );
  }
}
