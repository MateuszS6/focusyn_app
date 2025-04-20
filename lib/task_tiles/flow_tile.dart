import 'package:flutter/material.dart';
import 'package:focusyn_app/constants/theme_icons.dart';
import 'package:focusyn_app/constants/theme_colours.dart';
import 'package:focusyn_app/services/brain_points_service.dart';
import 'package:focusyn_app/services/flow_history_service.dart';
import 'package:focusyn_app/utils/task_tile.dart';
import 'package:focusyn_app/models/task_model.dart';

class FlowTile extends StatelessWidget {
  final Task task;
  final Function(Task updatedTask) onComplete;
  final VoidCallback onDelete;

  const FlowTile({
    super.key,
    required this.task,
    required this.onComplete,
    required this.onDelete,
  });

  bool _isOverdue() {
    if (task.date == null || task.date!.isEmpty) return false;

    final taskDate = DateTime.parse(task.date!);
    final now = DateTime.now();

    // Compare dates without time
    final taskDateOnly = DateTime(taskDate.year, taskDate.month, taskDate.day);
    final nowDateOnly = DateTime(now.year, now.month, now.day);

    return taskDateOnly.isBefore(nowDateOnly);
  }

  @override
  Widget build(BuildContext context) {
    final isOverdue = _isOverdue();
    final subtitleParts = [
      task.date,
      task.time,
      '${task.duration}m',
      task.repeat,
      '${task.brainPoints} BP',
      task.list,
    ];

    return TaskTile(
      key: key,
      color: ThemeColours.flowsAlt,
      text: task.text,
      subtitle: subtitleParts.join(" • "),
      subtitleStyle: TextStyle(
        color: isOverdue ? Colors.red : null,
        fontSize: 14,
      ),
      titleStyle: TextStyle(
        fontSize: 18,
        fontWeight: isOverdue ? FontWeight.bold : null,
      ),
      onDelete: onDelete,
      leading: IconButton(
        icon: const Icon(ThemeIcons.done),
        onPressed: () async {
          BrainPointsService.subtractPoints(task.brainPoints);

          // Record completion in the history service
          await FlowHistoryService.addCompletion(DateTime.now());

          // Calculate next date
          final nextDate = _calculateNextDate(task.repeat ?? 'Daily');

          final updatedTask = Task(
            id: task.id,
            text: task.text,
            priority: task.priority,
            brainPoints: task.brainPoints,
            list: task.list,
            date: nextDate.toIso8601String().split('T').first,
            time: task.time,
            duration: task.duration,
            location: task.location,
            repeat: task.repeat,
            history: task.history, // Keep the task's own history for reference
            createdAt: task.createdAt,
          );

          onComplete(updatedTask);
        },
      ),
    );
  }

  DateTime _calculateNextDate(String repeat) {
    final now = DateTime.now();
    switch (repeat) {
      case 'Daily':
        return now.add(const Duration(days: 1));
      case 'Weekly':
        return now.add(const Duration(days: 7));
      case 'Monthly':
        return DateTime(now.year, now.month + 1, now.day);
      default:
        return now;
    }
  }
}
