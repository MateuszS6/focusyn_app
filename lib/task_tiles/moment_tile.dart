import 'package:flutter/material.dart';
import 'base_task_tile.dart';

class MomentTile extends BaseTaskTile {
  const MomentTile({
    super.key,
    super.color,
    required super.task,
    required super.onEdit,
  });

  @override
  State<MomentTile> createState() => _MomentTileState();
}

class _MomentTileState extends BaseTaskTileState<MomentTile> {
  @override
  String getInitialText() => widget.task['title'] ?? '';

  @override
  Widget buildSubtitle() {
    final date = widget.task['date'];
    final time = widget.task['time'];
    final dur = widget.task['duration'];
    final duration = dur != null ? '$dur min' : '';
    final loc = widget.task['location'];
    final locText = loc != null && loc != '' ? ' • Location: $loc' : '';

    return Text(
      '$date • $time • $duration$locText',
      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
    );
  }
}
