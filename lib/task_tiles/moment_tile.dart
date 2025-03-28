import 'package:flutter/material.dart';
import 'base_task_tile.dart';

class MomentTile extends BaseTaskTile {
  const MomentTile({
    super.key,
    required super.task,
    required super.onEdit,
  });

  @override
  State<MomentTile> createState() => _MomentTileState();
}

class _MomentTileState extends BaseTaskTileState<MomentTile> {
  @override
  String getInitialText() => widget.task["title"] ?? '';

  @override
  Widget buildSubtitle() {
    final loc = widget.task["location"];
    final locText = loc != null && loc != "" ? ' • Location: $loc' : '';
    return Text(
      "${widget.task["date"] ?? 'N/A'} • ${widget.task["time"] ?? 'N/A'}$locText",
      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
    );
  }
}
