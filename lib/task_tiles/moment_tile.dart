import 'package:flutter/material.dart';
import 'package:focusyn_app/constants/theme_colours.dart';
import 'package:focusyn_app/constants/keys.dart';
import 'package:focusyn_app/utils/task_tile.dart';
import 'package:focusyn_app/models/task_model.dart';

/// A specialized task tile widget for displaying and managing moment tasks.
/// This widget provides:
/// - Visual representation of a moment task
/// - Location and duration information
/// - Overdue task highlighting
/// - Edit and delete functionality
class MomentTile extends StatelessWidget {
  /// The moment task to display
  final Task task;

  /// Callback function when the task is edited
  final VoidCallback onEdit;

  /// Callback function when the task is deleted
  final VoidCallback onDelete;

  /// Currently selected list name
  final String selectedList;

  /// Creates a moment task tile with the specified properties.
  ///
  /// [task] - The moment task to display
  /// [onEdit] - Callback when the task is edited
  /// [onDelete] - Callback when the task is deleted
  /// [selectedList] - Currently selected list name
  const MomentTile({
    super.key,
    required this.task,
    required this.onEdit,
    required this.onDelete,
    required this.selectedList,
  });

  @override
  Widget build(BuildContext context) {
    final isOverdue = Task.isOverdue(task.date!, task.time);
    final subtitleParts = [
      Task.formatDate(task.date!),
      task.time,
      '${task.duration}m',
      task.location,
      if (selectedList == Keys.all) task.list,
    ].where((item) => item != null && item.isNotEmpty);

    return TaskTile(
      key: key,
      color: ThemeColours.momentsAlt,
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
    );
  }
}
