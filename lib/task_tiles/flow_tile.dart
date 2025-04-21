import 'package:flutter/material.dart';
import 'package:focusyn_app/constants/keys.dart';
import 'package:focusyn_app/constants/theme_icons.dart';
import 'package:focusyn_app/constants/theme_colours.dart';
import 'package:focusyn_app/services/brain_points_service.dart';
import 'package:focusyn_app/services/flow_history_service.dart';
import 'package:focusyn_app/utils/task_tile.dart';
import 'package:focusyn_app/models/task_model.dart';

class FlowTile extends StatelessWidget {
  final Task task;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final Function(Task updatedTask) onComplete;
  final String selectedList;

  const FlowTile({
    super.key,
    required this.task,
    required this.onEdit,
    required this.onDelete,
    required this.onComplete,
    required this.selectedList,
  });

  @override
  Widget build(BuildContext context) {
    final isOverdue = task.isOverdue();
    final subtitleParts = [
      task.formatDate(),
      task.time,
      '${task.duration}m',
      task.repeat,
      '${task.brainPoints} BP',
      if (selectedList == Keys.all) task.list,
    ];

    return TaskTile(
      key: key,
      color: ThemeColours.flowsAlt,
      text: task.title,
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
      selectedList: selectedList,
      onEdit: onEdit,
      leading: IconButton(
        icon: const Icon(ThemeIcons.done),
        onPressed: () async {
          BrainPointsService.subtractPoints(task.brainPoints!);

          // Record completion in the history service
          await FlowHistoryService.addCompletion(DateTime.now());

          // Calculate next date
          final nextDate = _calculateNextDate(task.repeat ?? 'Daily');

          final updatedTask = Task(
            id: task.id,
            title: task.title,
            priority: task.priority,
            brainPoints: task.brainPoints,
            list: task.list,
            date: nextDate.toIso8601String().split('T').first,
            time: task.time,
            duration: task.duration,
            location: task.location,
            repeat: task.repeat,
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
