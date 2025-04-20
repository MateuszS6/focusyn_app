import 'package:flutter/material.dart';
import 'package:focusyn_app/constants/keys.dart';
import 'package:focusyn_app/constants/theme_icons.dart';
import 'package:focusyn_app/constants/theme_colours.dart';
import 'package:focusyn_app/services/brain_points_service.dart';
import 'package:focusyn_app/models/task_model.dart';
import 'package:focusyn_app/utils/task_tile.dart';

class ActionTile extends StatelessWidget {
  final Task task;
  final VoidCallback onEdit;
  final VoidCallback onComplete;
  final VoidCallback onDelete;
  final String? selectedFilter;

  const ActionTile({
    super.key,
    required this.task,
    required this.onEdit,
    required this.onComplete,
    required this.onDelete,
    required this.selectedFilter,
  });

  String _getPriorityText(int priority) {
    switch (priority) {
      case 1:
        return 'Urgent & Important';
      case 2:
        return 'Not Urgent but Important';
      case 3:
        return 'Urgent but Not Important';
      case 4:
        return 'Not Urgent & Not Important';
      default:
        return 'Unknown Priority';
    }
  }

  @override
  Widget build(BuildContext context) {
    final subtitle = [
      _getPriorityText(task.priority),
      '${task.brainPoints} BP',
      if (selectedFilter == Keys.all) task.list,
    ].join(' • ');

    return TaskTile(
      leading: IconButton(
        icon: const Icon(ThemeIcons.done),
        onPressed: () {
          BrainPointsService.subtractPoints(task.brainPoints);
          onComplete();
        },
      ),
      text: task.text,
      subtitle: subtitle,
      onDelete: onDelete,
      color: ThemeColours.actionsAlt,
      selectedFilter: selectedFilter,
    );
  }
}
