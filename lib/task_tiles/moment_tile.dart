import 'package:flutter/material.dart';
import 'package:focusyn_app/data/keys.dart';
import 'package:focusyn_app/task_tiles/task_tile.dart';

class MomentTile extends StatelessWidget {
  final Map<String, dynamic> task;
  final Color color;
  final Function(String title) onEdit;
  final VoidCallback onDelete;

  const MomentTile({
    super.key,
    required this.task,
    required this.color,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final title = task[Keys.title] ?? '';
    final location = task[Keys.location] ?? '';
    final tag = task[Keys.tag] ?? '';
    final date = task[Keys.date] ?? '';
    final time = task[Keys.time] ?? '';

    final subtitle = [
      if (date.isNotEmpty) date,
      if (time.isNotEmpty) time,
      if (location.isNotEmpty) location,
      if (tag.isNotEmpty) tag,
    ].join(" • ");

    return TaskTile(
      key: key,
      color: color,
      text: title,
      subtitle: subtitle,
      onInlineEdit: onEdit,
      onDelete: onDelete,
    );
  }
}
