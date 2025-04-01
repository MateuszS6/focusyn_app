import 'package:flutter/material.dart';
import 'package:focusyn_app/task_tiles/my_task_tile.dart';

class MomentTile extends StatefulWidget {
  final Map<String, dynamic> task;
  final Color color;
  final Function(String title) onEdit;

  const MomentTile({
    super.key,
    required this.task,
    required this.color,
    required this.onEdit,
  });

  @override
  State<MomentTile> createState() => _MomentTileState();
}

class _MomentTileState extends State<MomentTile> {
  bool _editing = false;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.task['title']);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final date = widget.task['date'] ?? 'Date?';
    final time = widget.task['time'] ?? 'Time?';
    final duration = widget.task['duration'] ?? 15;
    final location = widget.task['location'] ?? 'Nowhere?';

    return MyTaskTile(
      key: widget.key,
      color: widget.color,
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
                  widget.task['title'] ?? '',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
      subtitle: Text("$date • $time • $duration mins • $location"),
    );
  }
}
