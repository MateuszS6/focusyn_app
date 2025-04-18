import 'package:flutter/material.dart';
import 'package:focusyn_app/constants/theme_colours.dart';
import 'package:focusyn_app/utils/task_tile.dart';
import 'package:focusyn_app/models/task_model.dart';

class MomentTile extends StatelessWidget {
  final Task task;
  final Function(String title) onEdit;
  final VoidCallback onDelete;

  const MomentTile({
    super.key,
    required this.task,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final subtitle = [
      task.date,
      task.time,
      '${task.duration}m',
      task.location,
      task.list,
    ].join(" • ");

    return TaskTile(
      key: key,
      color: ThemeColours.momentsAlt,
      text: task.text,
      subtitle: subtitle,
      onInlineEdit: onEdit,
      onDelete: onDelete,
    );
  }
}
