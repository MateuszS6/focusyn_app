import 'package:flutter/material.dart';
import 'package:focusyn_app/constants/theme_colours.dart';
import 'package:focusyn_app/constants/theme_icons.dart';
import 'package:focusyn_app/services/task_service.dart';
import 'package:focusyn_app/constants/keys.dart';
import 'package:focusyn_app/utils/focus_card.dart';
import 'package:focusyn_app/pages/help_page.dart';

/// Represents a category of tasks in the application.
///
/// Each focus category has:
/// - A name (e.g., 'actions', 'flows', 'moments', 'thoughts')
/// - A description explaining its purpose
/// - An icon for visual representation
/// - A color key for consistent theming
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

/// A page that displays different categories of tasks (focuses).
///
/// This page provides:
/// - Overview of all task categories
/// - Task count statistics
/// - Visual representation of each focus
/// - Quick access to help information
class FocusesPage extends StatefulWidget {
  const FocusesPage({super.key});

  @override
  State<FocusesPage> createState() => _FocusesPageState();
}

/// Manages the state of the focuses page, including:
/// - Task category definitions
/// - Task statistics
/// - UI state for focus cards
class _FocusesPageState extends State<FocusesPage> {
  /// List of all available focus categories with their properties
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

  /// Gets the total number of tasks across all focus categories.
  int get _totalTasks {
    return _categories.fold(0, (sum, category) {
      return sum + (TaskService.tasks[category.name]?.length ?? 0);
    });
  }

  /// Gets the name of the focus category with the most tasks.
  ///
  /// Returns an empty string if no tasks exist in any category.
  String get _mostActiveFocus {
    int maxTasks = 0;
    String category = '';

    for (var c in _categories) {
      final count = TaskService.tasks[c.name]?.length ?? 0;
      if (count > maxTasks) {
        maxTasks = count;
        category = c.name;
      }
    }

    return category;
  }

  @override
  Widget build(BuildContext context) {
    // Calculate statistics
    final totalTasks = _totalTasks;
    final mostActive = _mostActiveFocus;
    // Determine the color for the most active focus
    final mostActiveColor = switch (mostActive) {
      Keys.actions => ThemeColours.actionsMain,
      Keys.flows => ThemeColours.flowsMain,
      Keys.moments => ThemeColours.momentsMain,
      Keys.thoughts => ThemeColours.thoughtsMain,
      _ => ThemeColours.taskMain,
    };

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with help button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Focuses',
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                  IconButton(
                    icon: const Icon(ThemeIcons.help),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const HelpPage()),
                      );
                    },
                    tooltip: 'Help & Definitions',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Task statistics section
              if (totalTasks > 0) ...[
                Text(
                  'You have $totalTasks items across your focuses',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: Colors.black54),
                ),
                if (mostActive.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: mostActiveColor.withAlpha(26),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          ThemeIcons.streak,
                          size: 16,
                          color: mostActiveColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '$mostActive is your most active focus',
                          style: TextStyle(
                            color: mostActiveColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ] else ...[
                // Empty state message
                Text(
                  'Start organizing your tasks into different focuses',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: Colors.black54),
                ),
              ],
              const SizedBox(height: 32),
              // Focus cards list
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children:
                      _categories.map((category) {
                        return FocusCard(
                          icon: category.icon,
                          color: switch (category.colorKey) {
                            Keys.actions => ThemeColours.actionsMain,
                            Keys.flows => ThemeColours.flowsMain,
                            Keys.moments => ThemeColours.momentsMain,
                            Keys.thoughts => ThemeColours.thoughtsMain,
                            _ => ThemeColours.taskMain,
                          },
                          category: category.name,
                          description: category.description,
                          onUpdate: () => setState(() {}),
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
