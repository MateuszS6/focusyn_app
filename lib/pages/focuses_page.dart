import 'package:flutter/material.dart';
import 'package:focusyn_app/constants/theme_constants.dart';
import 'package:focusyn_app/services/task_service.dart';
import 'package:focusyn_app/constants/keys.dart';
import 'package:focusyn_app/utils/focus_card.dart';

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
      icon: Icons.event_rounded,
      colorKey: Keys.moments,
    ),
    FocusCategory(
      name: Keys.thoughts,
      description: 'Your reflections for later',
      icon: Icons.lightbulb_rounded,
      colorKey: Keys.thoughts,
    ),
  ];

  int get _totalTasks {
    return _categories.fold(0, (sum, category) {
      return sum + (TaskService.instance.tasks[category.name]?.length ?? 0);
    });
  }

  String get _mostActiveFocus {
    int maxTasks = 0;
    String category = '';

    for (var c in _categories) {
      final count = TaskService.instance.tasks[c.name]?.length ?? 0;
      if (count > maxTasks) {
        maxTasks = count;
        category = c.name;
      }
    }

    return category;
  }

  @override
  Widget build(BuildContext context) {
    final totalTasks = _totalTasks;
    final mostActive = _mostActiveFocus;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Focuses', style: Theme.of(context).textTheme.displayLarge),
              const SizedBox(height: 12),
              if (totalTasks > 0) ...[
                Text(
                  'You have $totalTasks active items across your focuses',
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
                      color: ThemeConstants.focusColors[mostActive]!['main']!
                          .withAlpha(26),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.local_fire_department_rounded,
                          size: 16,
                          color:
                              ThemeConstants.focusColors[mostActive]!['main']!,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '$mostActive is your most active focus',
                          style: TextStyle(
                            color:
                                ThemeConstants
                                    .focusColors[mostActive]!['main']!,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ] else ...[
                Text(
                  'Start organizing your tasks into different focuses',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: Colors.black54),
                ),
              ],
              const SizedBox(height: 32),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children:
                      _categories.map((category) {
                        return FocusCard(
                          icon: category.icon,
                          color:
                              ThemeConstants.focusColors[category
                                  .colorKey]!['main']!,
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
