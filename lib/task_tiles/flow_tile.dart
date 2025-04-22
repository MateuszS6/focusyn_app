import 'package:flutter/material.dart';
import 'package:focusyn_app/constants/keys.dart';
import 'package:focusyn_app/constants/theme_icons.dart';
import 'package:focusyn_app/constants/theme_colours.dart';
import 'package:focusyn_app/services/brain_points_service.dart';
import 'package:focusyn_app/services/flow_history_service.dart';
import 'package:focusyn_app/utils/task_tile.dart';
import 'package:focusyn_app/models/task_model.dart';

/// A specialized task tile widget for displaying and managing flow tasks.
/// This widget provides:
/// - Visual representation of a flow task with completion status
/// - Brain points tracking and history recording
/// - Automatic date calculation for recurring tasks
/// - Overdue task highlighting
class FlowTile extends StatelessWidget {
  /// The flow task to display
  final Task task;

  /// Callback function when the task is edited
  final VoidCallback onEdit;

  /// Callback function when the task is deleted
  final VoidCallback onDelete;

  /// Callback function when the task is completed, providing the updated task
  final Function(Task updatedTask) onComplete;

  /// Currently selected list name
  final String selectedList;

  /// Creates a flow task tile with the specified properties.
  ///
  /// [task] - The flow task to display
  /// [onEdit] - Callback when the task is edited
  /// [onDelete] - Callback when the task is deleted
  /// [onComplete] - Callback when the task is completed
  /// [selectedList] - Currently selected list name
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
    final isOverdue = Task.isOverdue(task.date!, task.time);
    final subtitleParts = [
      Task.formatDate(task.date!),
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
          final nextDate = Task.calculateNextDate(task.repeat ?? 'Daily');

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
}
