import 'package:flutter/material.dart';
import 'base_task_tile.dart';

class ActionTile extends BaseTaskTile {
  final VoidCallback onComplete;

  const ActionTile({
    super.key,
    super.color,
    required super.task,
    required super.onEdit,
    required this.onComplete,
  });

  @override
  State<ActionTile> createState() => _ActionTileState();
}

class _ActionTileState extends BaseTaskTileState<ActionTile> {
  @override
  String getInitialText() => widget.task['title'] ?? '';

  @override
  Widget? buildTrailing() {
    return IconButton(
      icon: Icon(Icons.check_rounded),
      onPressed: widget.onComplete,
    );
  }

  @override
  Widget buildSubtitle() {
    final priority = widget.task['priority'];
    final brainPoints = widget.task['brainPoints'];

    return Text(
      'Priority: $priority • Brain Points: $brainPoints',
      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
    );
  }
}
