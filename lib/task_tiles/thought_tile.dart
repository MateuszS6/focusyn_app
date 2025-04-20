import 'package:flutter/material.dart';
import 'package:focusyn_app/constants/theme_colours.dart';
import 'package:focusyn_app/utils/task_tile.dart';
import 'package:focusyn_app/models/task_model.dart';

class ThoughtTile extends StatelessWidget {
  final Task task;
  final VoidCallback onDelete;

  const ThoughtTile({super.key, required this.task, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return TaskTile(
      key: key,
      color: ThemeColours.thoughtsAlt,
      text: task.text,
      subtitle: task.list,
      onDelete: onDelete,
    );
  }
}
