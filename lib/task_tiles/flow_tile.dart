import 'package:flutter/material.dart';
import 'base_task_tile.dart';

class FlowTile extends BaseTaskTile {
  const FlowTile({
    super.key,
    super.color,
    required super.task,
    required super.onEdit,
  });

  @override
  State<FlowTile> createState() => _FlowTileState();
}

class _FlowTileState extends BaseTaskTileState<FlowTile> {
  @override
  String getInitialText() => widget.task['title'] ?? '';

  @override
  Widget buildSubtitle() {
    final date = widget.task['date'] ?? 'N/A';
    final time = widget.task['time'] ?? 'N/A';
    final duration = widget.task['duration'] ?? 15;
    final repeat = widget.task['repeat'] ?? 'None';

    return Text(
      '$date • $time • $duration min • $repeat',
      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
    );
  }
}
