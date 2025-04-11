import 'package:flutter/material.dart';
import 'package:focusyn_app/models/task_model.dart';
import 'package:focusyn_app/util/task_tile.dart';

class ActionTile extends StatelessWidget {
  final Task task;
  final Color color;
  final VoidCallback onEdit;
  final VoidCallback onComplete;
  final VoidCallback onDelete;

  const ActionTile({
    super.key,
    required this.task,
    required this.color,
    required this.onEdit,
    required this.onComplete,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return TaskTile(
      leading: IconButton(
        icon: const Icon(Icons.check_circle_outline),
        onPressed: onComplete,
      ),
      text: task.title,
      onInlineEdit: (newTitle) {
        if (newTitle.isNotEmpty) {
          onEdit();
        }
      },
      onDelete: onDelete,
      color: color,
    );
  }
}
