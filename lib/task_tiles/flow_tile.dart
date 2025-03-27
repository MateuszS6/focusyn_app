import 'package:flutter/material.dart';
import 'base_task_tile.dart';

class FlowTile extends BaseTaskTile {
  const FlowTile({
    super.key,
    required super.task,
    required super.onEdit,
  });

  @override
  State<FlowTile> createState() => _FlowTileState();
}

class _FlowTileState extends BaseTaskTileState<FlowTile> {
  @override
  String getInitialText() => widget.task["title"] ?? '';

  @override
  Widget buildSubtitle() {
    return Text(
      "Due: ${widget.task["dueDate"] ?? 'N/A'} • Time: ${widget.task["time"] ?? 'N/A'} • Repeat: ${widget.task["repeat"] ?? 'None'}",
      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
    );
  }
}
