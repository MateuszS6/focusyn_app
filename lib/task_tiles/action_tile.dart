import 'package:flutter/material.dart';
import 'base_task_tile.dart';

class ActionTile extends BaseTaskTile {
  final VoidCallback onComplete;

  const ActionTile({
    super.key,
    required super.task,
    required super.onEdit,
    required this.onComplete,
  });

  @override
  State<ActionTile> createState() => _ActionTileState();
}

class _ActionTileState extends BaseTaskTileState<ActionTile> {
  @override
  String getInitialText() => widget.task["title"] ?? '';

  @override
  Widget? buildTrailing() {
    return IconButton(
      icon: Icon(Icons.check_rounded),
      onPressed: widget.onComplete,
    );
  }

  @override
  Widget buildSubtitle() {
    return Text(
      "Priority: ${widget.task["priority"]} • Brain Points: ${widget.task["brainPoints"]}",
      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
    );
  }
}