import 'package:flutter/material.dart';
import 'package:focusyn_app/constants/keys.dart';
import 'package:focusyn_app/constants/theme_colours.dart';
import 'package:focusyn_app/utils/task_tile.dart';
import 'package:focusyn_app/models/task_model.dart';

class ThoughtTile extends StatelessWidget {
  final Task task;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final String selectedList;

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
