import 'package:flutter/material.dart';
import 'package:focusyn_app/data/brain_points_service.dart';
import 'package:focusyn_app/data/keys.dart';
import 'package:focusyn_app/util/task_tile.dart';

class FlowTile extends StatelessWidget {
  final Map<String, dynamic> task;
  final Color color;
  final Function(String title) onEdit;
  final VoidCallback onComplete;
  final VoidCallback onDelete;

  const FlowTile({
    super.key,
    required this.task,
    required this.color,
    required this.onEdit,
    required this.onComplete,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final title = task[Keys.title] ?? '';
    final date = task[Keys.date] ?? '';
    final time = task[Keys.time] ?? '';
    final duration = task[Keys.duration] ?? 15;
    final repeat = task[Keys.repeat] ?? 'Repeat?';
    final bp = task[Keys.brainPoints] ?? 0;
    final tag = task[Keys.tag] ?? 'All';

    final subtitle = [
      if (date.isNotEmpty) date,
      if (time.isNotEmpty) time,
      duration,
      if (repeat.isNotEmpty) repeat,
      '$bp BP',
      if (tag.isNotEmpty) tag,
    ].join(" • ");

    return TaskTile(
      key: key,
      color: color,
      text: title,
      subtitle: subtitle,
      onInlineEdit: onEdit,
      onDelete: onDelete,
      leading: IconButton(
        icon: const Icon(Icons.check_rounded),
        onPressed: () {
          BrainPointsService.subtract(bp);

          // Update to next scheduled date
          final repeat = task[Keys.repeat] ?? 'Daily';
          final nextDate = _calculateNextDate(repeat);
          task[Keys.date] = nextDate.toIso8601String().split('T').first;

          onComplete();
        },
      ),
    );
  }

  DateTime _calculateNextDate(String repeat) {
    final now = DateTime.now();
    switch (repeat.toLowerCase()) {
      case 'weekly':
        return now.add(const Duration(days: 7));
      case 'monthly':
        return DateTime(now.year, now.month + 1, now.day);
      case 'daily':
      default:
        return now.add(const Duration(days: 1));
    }
  }
}
