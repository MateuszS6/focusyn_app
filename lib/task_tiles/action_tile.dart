import 'package:flutter/material.dart';
import 'package:focusyn_app/constants/keys.dart';
import 'package:focusyn_app/constants/theme_icons.dart';
import 'package:focusyn_app/constants/theme_colours.dart';
import 'package:focusyn_app/services/brain_points_service.dart';
import 'package:focusyn_app/models/task_model.dart';
import 'package:focusyn_app/utils/task_tile.dart';

/// A specialized task tile widget for displaying and managing action tasks.
/// This widget provides:
/// - Visual representation of an action task
/// - Priority and brain points information
/// - Task completion with brain points tracking
/// - Edit and delete functionality
class ActionTile extends StatelessWidget {
  /// The action task to display
  final Task task;

  /// Callback function when the task is edited
  final VoidCallback onEdit;

  /// Callback function when the task is completed
  final VoidCallback onComplete;

  /// Callback function when the task is deleted
  final VoidCallback onDelete;

  /// Currently selected list name
  final String selectedList;

  /// Creates an action task tile with the specified properties.
  ///
  /// [task] - The action task to display
  /// [onEdit] - Callback when the task is edited
  /// [onComplete] - Callback when the task is completed
  /// [onDelete] - Callback when the task is deleted
  /// [selectedList] - Currently selected list name
  const ActionTile({
    super.key,
    required this.task,
    required this.onEdit,
    required this.onComplete,
    required this.onDelete,
    required this.selectedList,
  });

  @override
  Widget build(BuildContext context) {
    final subtitle = [
      Task.getPriorityText(task.priority!),
      '${task.brainPoints} BP',
      if (selectedList == Keys.all) task.list,
    ].join(' • ');

    return TaskTile(
      leading: IconButton(
        icon: const Icon(ThemeIcons.done),
        onPressed: () {
          BrainPointsService.subtractPoints(task.brainPoints!);
          onComplete();
        },
      ),
      text: task.title,
      subtitle: subtitle,
      onEdit: onEdit,
      onDelete: onDelete,
      color: ThemeColours.actionsAlt,
      selectedList: selectedList,
    );
  }
}
