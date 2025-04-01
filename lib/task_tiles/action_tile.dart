import 'package:flutter/material.dart';
import 'package:focusyn_app/data/brain_points_service.dart';
import 'package:focusyn_app/data/keys.dart';
import 'package:focusyn_app/task_tiles/my_task_tile.dart';

class ActionTile extends StatefulWidget {
  final Map<String, dynamic> task;
  final Color color;
  final Function(String title) onEdit;
  final VoidCallback onComplete;

  const ActionTile({
    super.key,
    required this.task,
    required this.color,
    required this.onEdit,
    required this.onComplete,
  });

  @override
  State<ActionTile> createState() => _ActionTileState();
}

class _ActionTileState extends State<ActionTile> {
  bool _editing = false;
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.task[Keys.title]);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final priority = widget.task[Keys.priority] ?? 'Priority?';
    final brainPoints = widget.task[Keys.brainPoints] ?? 10;

    return MyTaskTile(
      key: widget.key,
      color: widget.color,
      leading: IconButton(
        icon: const Icon(Icons.check_rounded),
        onPressed: () {
          BrainPointsService.subtract(brainPoints);
          widget.onComplete();
        },
      ),
      title:
          _editing
              ? TextField(
                controller: _controller,
                onSubmitted: (val) {
                  if (val.trim().isNotEmpty) widget.onEdit(val.trim());
                  setState(() => _editing = false);
                },
              )
              : GestureDetector(
                onTap: () => setState(() => _editing = true),
                child: Text(
                  widget.task[Keys.title] ?? '',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
      subtitle: Text(
        "Priority: $priority • $brainPoints pts",
      ),
    );
  }
}
