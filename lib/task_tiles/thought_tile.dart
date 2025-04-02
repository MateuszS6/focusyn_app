import 'package:flutter/material.dart';
import 'package:focusyn_app/task_tiles/task_tile.dart';

class ThoughtTile extends StatefulWidget {
  final Map<String, dynamic> task;
  final Color color;
  final Function(String text) onEdit;

  const ThoughtTile({
    super.key,
    required this.task,
    required this.color,
    required this.onEdit,
  });

  @override
  State<ThoughtTile> createState() => _ThoughtTileState();
}

class _ThoughtTileState extends State<ThoughtTile> {
  bool _editing = false;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.task['text']);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TaskTile(
      key: widget.key,
      color: widget.color,
      title:
          _editing
              ? TextField(
                controller: _controller,
                maxLines: null,
                onSubmitted: (val) {
                  if (val.trim().isNotEmpty) widget.onEdit(val.trim());
                  setState(() => _editing = false);
                },
              )
              : GestureDetector(
                onTap: () => setState(() => _editing = true),
                child: Text(
                  widget.task['text'] ?? '',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
    );
  }
}
