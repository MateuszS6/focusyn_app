import 'package:flutter/material.dart';
import 'package:focusyn_app/constants/keys.dart';
import 'package:focusyn_app/constants/theme_colours.dart';
import 'package:focusyn_app/utils/task_tile.dart';

class ThoughtTile extends StatelessWidget {
  final Map<String, dynamic> task;
  final Function(String text) onEdit;
  final VoidCallback onDelete;

  const ThoughtTile({
    super.key,
    required this.task,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final text = task[Keys.text] ?? '';
    final tag = task[Keys.tag] ?? '';

    return TaskTile(
      key: key,
      color: ThemeColours.thoughtsTask,
      text: text,
      subtitle: tag.isNotEmpty ? tag : null,
      onInlineEdit: onEdit,
      onDelete: onDelete,
    );
  }
}
