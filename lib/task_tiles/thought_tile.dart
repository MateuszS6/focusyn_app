import 'package:flutter/material.dart';
import 'base_task_tile.dart';

class ThoughtTile extends BaseTaskTile {
  const ThoughtTile({
    super.key,
    required super.task,
    required super.onEdit,
  });

  @override
  State<ThoughtTile> createState() => _ThoughtTileState();
}

class _ThoughtTileState extends BaseTaskTileState<ThoughtTile> {
  @override
  String getInitialText() => widget.task["text"] ?? '';

  @override
  Widget buildSubtitle() => const SizedBox(); // No subtitle for Thoughts
}
