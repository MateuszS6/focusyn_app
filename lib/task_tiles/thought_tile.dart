import 'package:flutter/material.dart';
import 'package:focusyn_app/data/keys.dart';
import 'package:focusyn_app/util/task_tile.dart';

class ThoughtTile extends StatelessWidget {
  final Map<String, dynamic> task;
  final Color color;
  final Function(String text) onEdit;
  final VoidCallback onDelete;

  const ThoughtTile({
    super.key,
    required this.task,
    required this.color,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final text = task[Keys.text] ?? '';
    final tag = task[Keys.tag] ?? '';

    return TaskTile(
      key: key,
      color: color,
      text: text,
      subtitle: tag.isNotEmpty ? tag : null,
      onInlineEdit: onEdit,
      onDelete: onDelete,
    );
  }
}
