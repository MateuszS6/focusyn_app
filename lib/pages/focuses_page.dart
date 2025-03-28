import 'package:flutter/material.dart';
import 'package:focusyn_app/util/focus_card.dart';

class FocusesPage extends StatefulWidget {
  const FocusesPage({super.key});

  @override
  State<FocusesPage> createState() => _FocusesPageState();
}

class _FocusesPageState extends State<FocusesPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0),
          child: Text(
            'Organise your tasks, habits, and events',
            style: TextStyle(fontSize: 20.0, color: Colors.grey[600]),
          ),
        ),
        const FocusCard(
          icon: Icons.category_rounded,
          category: 'Actions',
          description: 'Your unscheduled to-do list',
        ),
        const FocusCard(
          icon: Icons.update_rounded,
          category: 'Flows',
          description: 'Your routines and habits',
        ),
        const FocusCard(
          icon: Icons.event_rounded,
          category: 'Moments',
          description: 'Your events and deadlines',
        ),
        const FocusCard(
          icon: Icons.lightbulb_outline_rounded,
          category: 'Thoughts',
          description: 'Your reflections for later',
        ),
      ],
    );
  }
}
