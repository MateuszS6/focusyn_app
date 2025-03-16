import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        Text(
          'Hi, Mateusz!',
          style: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16.0),
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
          '[Button]\nTry to break down your tasks into smaller, more manageable chunks.',
          style: TextStyle(fontSize: 16.0),
        ),
        const SizedBox(height: 48.0),
        Text(
          'Quick Links',
          style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
        ),
        Text(
          '[Button] Self-care\n[Button] Motivational quote',
          style: TextStyle(fontSize: 16.0),
        ),
      ],
    );
  }
}
