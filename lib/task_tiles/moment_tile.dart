import 'package:flutter/material.dart';
import 'package:focusyn_app/constants/theme_colours.dart';
import 'package:focusyn_app/constants/keys.dart';
import 'package:focusyn_app/utils/task_tile.dart';
import 'package:focusyn_app/models/task_model.dart';

class MomentTile extends StatelessWidget {
  final Task task;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final String selectedList;

  const MomentTile({
    super.key,
    required this.task,
    required this.onEdit,
    required this.onDelete,
    required this.selectedList,
  });

  @override
  Widget build(BuildContext context) {
    final isOverdue = task.isOverdue();
    final subtitleParts = [
      task.formatDate(),
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
