import 'package:flutter/material.dart';
import 'package:focusyn_app/constants/keys.dart';
import 'package:focusyn_app/constants/theme_colours.dart';
import 'package:focusyn_app/utils/task_tile.dart';
import 'package:focusyn_app/models/task_model.dart';

/// A specialized task tile widget for displaying and managing thought tasks.
/// This widget provides:
/// - Visual representation of a thought task
/// - Simple title and list information
/// - Edit and delete functionality
class ThoughtTile extends StatelessWidget {
  /// The thought task to display
  final Task task;

  /// Callback function when the task is edited
  final VoidCallback onEdit;

  /// Callback function when the task is deleted
  final VoidCallback onDelete;

  /// Currently selected list name
  final String selectedList;

  /// Creates a thought task tile with the specified properties.
  ///
  /// [task] - The thought task to display
  /// [onEdit] - Callback when the task is edited
  /// [onDelete] - Callback when the task is deleted
  /// [selectedList] - Currently selected list name
  const ThoughtTile({
    super.key,
    required this.task,
    required this.onEdit,
    required this.onDelete,
    required this.selectedList,
  });

  @override
  Widget build(BuildContext context) {
    return TaskTile(
      key: key,
      color: ThemeColours.thoughtsAlt,
      text: task.title,
      subtitle: selectedList == Keys.all ? task.list : null,
      onDelete: onDelete,
      selectedList: selectedList,
      onEdit: onEdit,
    );
  }
}
