import 'package:flutter/material.dart';
import 'package:focusyn_app/data/brain_points_service.dart';
import 'package:focusyn_app/task_tiles/my_task_tile.dart';

class FlowTile extends StatefulWidget {
  final Map<String, dynamic> task;
  final Color color;
  final Function(String title) onEdit;
  final VoidCallback onUpdate;

  const FlowTile({
    super.key,
    required this.task,
    required this.color,
    required this.onEdit,
    required this.onUpdate,
  });

  @override
  State<FlowTile> createState() => _FlowTileState();
}

class _FlowTileState extends State<FlowTile> {
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

  void _markCompleted() {
    BrainPointsService.subtract(widget.task['brainPoints'] ?? 0);

    final current = widget.task['date'];
    final repeat = widget.task['repeat'] ?? 'None';

    if (current != null && repeat != 'None') {
      final lastDate = DateTime.tryParse(current) ?? DateTime.now();
      final now = DateTime.now();
      DateTime nextDate = lastDate;

      Duration increment;
      switch (repeat) {
        case 'Daily':
          increment = const Duration(days: 1);
          break;
        case 'Weekly':
          increment = const Duration(days: 7);
          break;
        case 'Monthly':
          increment = const Duration(days: 30);
          break;
        default:
          increment = Duration.zero;
      }

      while (nextDate.isBefore(now)) {
        nextDate = nextDate.add(increment);
      }

      setState(() {
        widget.task['date'] = nextDate.toIso8601String().split('T').first;
      });
    }

    widget.onUpdate(); // This saves Hive
  }

  @override
  Widget build(BuildContext context) {
    final date = widget.task['date'] ?? 'Date?';
    final time = widget.task['time'] ?? 'Time?';
    final duration = widget.task['duration'] ?? 15;
    final repeat = widget.task['repeat'] ?? 'Repeat?';
    final brainPoints = widget.task['brainPoints'] ?? 10;

    return MyTaskTile(
      key: widget.key,
      color: widget.color,
      leading: IconButton(
        icon: const Icon(Icons.check_rounded),
        onPressed: _markCompleted,
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
                  widget.task['title'] ?? '',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
      subtitle: Text(
        "$date • $time • $duration mins • $repeat • $brainPoints pts",
      ),
    );
  }
}
