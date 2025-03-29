import 'package:flutter/material.dart';

class HubPage extends StatefulWidget {
  const HubPage({super.key});

  @override
  State<HubPage> createState() => _HubPageState();
}

class _HubPageState extends State<HubPage> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        Text(
          'Something here',
          style: TextStyle(fontSize: 16.0, fontStyle: FontStyle.italic),
        ),
        const SizedBox(height: 48.0),
        Text(
          'Today\'s Breakdown',
          style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
        ),
        Text(
          'You have 3 tasks due today.\nYou have 1 task overdue.',
          style: TextStyle(fontSize: 16.0, fontStyle: FontStyle.italic),
        ),
        const SizedBox(height: 48.0),
        Text(
          'Feeling Overwhelmed?',
          style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
        ),
        Text(
          'Try to break down your tasks into smaller, more manageable chunks.',
          style: TextStyle(fontSize: 16.0),
        ),
        const SizedBox(height: 48.0),
        Text(
          'Quick Links',
          style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
        ),
        Text('Self-care', style: TextStyle(fontSize: 16.0)),
        Text('Motivational quote', style: TextStyle(fontSize: 16)),
      ],
    );
  }
}
