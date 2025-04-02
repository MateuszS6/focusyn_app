import 'package:flutter/material.dart';
import 'package:focusyn_app/data/brain_points_service.dart';
import 'package:focusyn_app/data/keys.dart';
import 'package:focusyn_app/task_tiles/task_tile.dart';

class FlowTile extends StatefulWidget {
  final Map<String, dynamic> task;
  final Color color;
  final Function(String title) onEdit;
  final VoidCallback onComplete;

  const FlowTile({
    super.key,
    required this.task,
    required this.color,
    required this.onEdit,
    required this.onComplete,
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
    _controller = TextEditingController(text: widget.task[Keys.title]);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateDate() {
    final currentDate = widget.task[Keys.date];
    final repeat = widget.task[Keys.repeat];

    if (currentDate == null || repeat == null) return;

    final now = DateTime.now();
    final lastDate = DateTime.tryParse(currentDate) ?? now;
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
        debugPrint("⚠️ Invalid repeat value: $repeat");
        return; // Exit early to avoid infinite loop
    }

    if (increment.inMilliseconds == 0) return;

    // Prevent infinite loop
    int maxCycles = 100;
    while (nextDate.isBefore(now) && maxCycles-- > 0) {
      nextDate = nextDate.add(increment);
    }

    setState(() {
      widget.task[Keys.date] = nextDate.toIso8601String().split('T').first;

      final history = widget.task[Keys.history];
      if (history is List<String>) {
        history.add(DateTime.now().toIso8601String().split('T').first);
      } else {
        widget.task[Keys.history] = [
          DateTime.now().toIso8601String().split('T').first,
        ];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final date = widget.task[Keys.date] ?? DateTime.now();
    final time = widget.task[Keys.time] ?? 'time?';
    final duration = widget.task[Keys.duration] ?? 15;
    final repeat = widget.task[Keys.repeat] ?? 'repeat?';
    final brainPoints = widget.task[Keys.brainPoints] ?? 10;

    return TaskTile(
      key: widget.key,
      color: widget.color,
      leading: IconButton(
        icon: const Icon(Icons.check_rounded),
        onPressed: () {
          _updateDate();
          BrainPointsService.subtract(brainPoints);
          widget.onComplete(); // This saves Hive
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
        [date, time, '$duration mins', repeat, '$brainPoints pts'].join(" • "),
      ),
    );
  }
}
