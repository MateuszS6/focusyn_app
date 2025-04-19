import 'package:flutter/material.dart';
import 'package:focusyn_app/constants/theme_icons.dart';
import 'package:focusyn_app/constants/theme_colours.dart';
import 'package:focusyn_app/services/brain_points_service.dart';
import 'package:focusyn_app/utils/task_tile.dart';
import 'package:focusyn_app/models/task_model.dart';

class FlowTile extends StatelessWidget {
  final Task task;
  final Function(String title) onEdit;
  final Function(Task updatedTask) onComplete;
  final VoidCallback onDelete;

  const FlowTile({
    super.key,
    required this.task,
    required this.onEdit,
    required this.onComplete,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final subtitle = [
      task.date,
      task.time,
      '${task.duration}m',
      task.repeat,
      '${task.brainPoints} BP',
      task.list,
    ].join(" • ");

    return TaskTile(
      key: key,
      color: ThemeColours.flowsAlt,
      text: task.text,
      subtitle: subtitle,
      onInlineEdit: onEdit,
      onDelete: onDelete,
      leading: IconButton(
        icon: const Icon(ThemeIcons.check),
        onPressed: () {
          BrainPointsService.subtractPoints(task.brainPoints);

          // Record completion and update date
          final history = List<String>.from(task.history)
            ..add(DateTime.now().toIso8601String());
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
            history: history,
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
