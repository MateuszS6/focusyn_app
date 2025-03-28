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
      "${widget.task["dueDate"] ?? 'N/A'} • ${widget.task["time"] ?? 'N/A'} • ${widget.task["repeat"] ?? 'None'}",
      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
    );
  }
}
