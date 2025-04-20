import 'package:flutter/material.dart';
import 'package:focusyn_app/constants/theme_colours.dart';
import 'package:focusyn_app/constants/keys.dart';
import 'package:focusyn_app/utils/task_tile.dart';
import 'package:focusyn_app/models/task_model.dart';

class MomentTile extends StatelessWidget {
  final Task task;
  final VoidCallback onDelete;
  final String? selectedFilter;

  const MomentTile({
    super.key,
    required this.task,
    required this.onDelete,
    required this.selectedFilter,
  });

  bool _isOverdue() {
    if (task.date == null || task.date!.isEmpty) return false;

    final taskDate = DateTime.parse(task.date!);
    final now = DateTime.now();

    // Compare dates without time
    final taskDateOnly = DateTime(taskDate.year, taskDate.month, taskDate.day);
    final nowDateOnly = DateTime(now.year, now.month, now.day);

    return taskDateOnly.isBefore(nowDateOnly);
  }

  @override
  Widget build(BuildContext context) {
    final isOverdue = _isOverdue();
    final subtitleParts = [
      TaskTile.formatDate(task.date),
      task.time,
      '${task.duration}m',
      task.location,
      if (selectedFilter == Keys.all) task.list,
    ].where((item) => item != null && item.isNotEmpty);

    return TaskTile(
      key: key,
      color: ThemeColours.momentsAlt,
      text: task.text,
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
      selectedFilter: selectedFilter,
    );
  }
}
