import 'package:flutter/material.dart';
import 'package:focusyn_app/data/app_data.dart';
import 'package:focusyn_app/util/focus_card.dart';

class FocusesPage extends StatefulWidget {
  const FocusesPage({super.key});

  @override
  State<FocusesPage> createState() => _FocusesPageState();
}

class _FocusesPageState extends State<FocusesPage> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        FocusCard(
          icon: Icons.category_rounded,
          color: AppData.instance.colours['Actions']!['main']!,
          category: 'Actions',
          description: 'Your unscheduled to-do list',
        ),
        FocusCard(
          icon: Icons.update_rounded,
          color: AppData.instance.colours['Flows']!['main']!,
          category: 'Flows',
          description: 'Your routines and habits',
        ),
        FocusCard(
          icon: Icons.event_rounded,
          color: AppData.instance.colours['Moments']!['main']!,
          category: 'Moments',
          description: 'Your events and deadlines',
        ),
        FocusCard(
          icon: Icons.lightbulb_outline_rounded,
          color: AppData.instance.colours['Thoughts']!['main']!,
          category: 'Thoughts',
          description: 'Your reflections for later',
        ),
      ],
    );
  }
}
