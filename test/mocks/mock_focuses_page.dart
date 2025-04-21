import 'package:flutter/material.dart';
import 'package:focusyn_app/constants/theme_colours.dart';
import 'package:focusyn_app/constants/theme_icons.dart';
import 'package:focusyn_app/constants/keys.dart';

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

class MockFocusesPage extends StatelessWidget {
  static const List<FocusCategory> _categories = [
    FocusCategory(
      name: Keys.actions,
      description: 'Your unscheduled to-do list',
      icon: ThemeIcons.actions,
      colorKey: Keys.actions,
    ),
    FocusCategory(
      name: Keys.flows,
      description: 'Your routines and habits',
      icon: ThemeIcons.flows,
      colorKey: Keys.flows,
    ),
    FocusCategory(
      name: Keys.moments,
      description: 'Your events and deadlines',
      icon: ThemeIcons.moments,
      colorKey: Keys.moments,
    ),
    FocusCategory(
      name: Keys.thoughts,
      description: 'Your reflections for later',
      icon: ThemeIcons.thoughts,
      colorKey: Keys.thoughts,
    ),
  ];

  const MockFocusesPage({super.key});

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
              const SizedBox(height: 32),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children:
                      _categories.map((category) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Material(
                            color: switch (category.colorKey) {
                              Keys.actions => ThemeColours.actionsMain,
                              Keys.flows => ThemeColours.flowsMain,
                              Keys.moments => ThemeColours.momentsMain,
                              Keys.thoughts => ThemeColours.thoughtsMain,
                              _ => ThemeColours.taskMain,
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: InkWell(
                              onTap: () {},
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      category.name,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      category.description,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
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
