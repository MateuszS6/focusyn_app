import 'package:flutter/material.dart';
import 'package:focusyn_app/data/brain_points_service.dart';
import 'package:focusyn_app/data/keys.dart';
import 'package:focusyn_app/util/task_tile.dart';

class ActionTile extends StatelessWidget {
  final Map<String, dynamic> task;
  final Color color;
  final Function(String title) onEdit;
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
    final priority = task[Keys.priority] ?? 1;
    final brainPoints = task[Keys.brainPoints] ?? 0;
    final tag = task[Keys.tag] ?? 'All';

    return TaskTile(
      key: key,
      color: color,
      text: task[Keys.title] ?? '',
      subtitle: "Priority $priority • $brainPoints BP • $tag",
      onInlineEdit: onEdit,
      onDelete: onDelete,
      leading: IconButton(
        icon: const Icon(Icons.check_rounded),
        onPressed: () {
          BrainPointsService.subtract(brainPoints);
          onComplete();
        },
      ),
    );
  }
}
