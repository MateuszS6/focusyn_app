import 'package:flutter/material.dart';
import 'package:focusyn_app/data/app_data.dart';
import 'package:focusyn_app/data/keys.dart';
import 'package:focusyn_app/util/focus_card.dart';

class FocusCategory {
  final String name;
  final String description;
  final IconData icon;
  final String colorKey;

  const FocusCategory({
    required this.name,
    required this.description,
    required this.icon,
    required this.colorKey,
  });
}

class FocusesPage extends StatefulWidget {
  const FocusesPage({super.key});

  @override
  State<FocusesPage> createState() => _FocusesPageState();
}

class _FocusesPageState extends State<FocusesPage> {
  static const List<FocusCategory> _categories = [
    FocusCategory(
      name: Keys.actions,
      description: 'Your unscheduled to-do list',
      icon: Icons.check_circle_rounded,
      colorKey: Keys.actions,
    ),
    FocusCategory(
      name: Keys.flows,
      description: 'Your routines and habits',
      icon: Icons.replay_circle_filled_rounded,
      colorKey: Keys.flows,
    ),
    FocusCategory(
      name: Keys.moments,
      description: 'Your events and deadlines',
      icon: Icons.calendar_today_rounded,
      colorKey: Keys.moments,
    ),
    FocusCategory(
      name: Keys.thoughts,
      description: 'Your reflections for later',
      icon: Icons.lightbulb_rounded,
      colorKey: Keys.thoughts,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Focuses', style: Theme.of(context).textTheme.displayLarge),
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  children:
                      _categories.map((category) {
                        return FocusCard(
                          icon: category.icon,
                          color:
                              AppData.instance.colours[category
                                  .colorKey]!['main']!,
                          category: category.name,
                          description: category.description,
                        );
                      }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
