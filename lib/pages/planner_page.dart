import 'package:flutter/material.dart';
import 'package:focusyn_app/app_data.dart';

class PlannerPage extends StatefulWidget {
  const PlannerPage({super.key});

  @override
  State<PlannerPage> createState() => _PlannerPageState();
}

class _PlannerPageState extends State<PlannerPage> {
  DateTime selectedDate = DateTime.now();

  List<Map<String, dynamic>> get allScheduledTasks {
    final formattedDate = _formatDate(selectedDate);
    final flows =
        AppData.instance.tasks["Flows"]!
            .where((t) => t["date"] == formattedDate)
            .toList();

    final moments =
        AppData.instance.tasks["Moments"]!
            .where((t) => t["date"] == formattedDate)
            .toList();

    return [...flows, ...moments]
      ..sort((a, b) => _parseTime(a["time"]).compareTo(_parseTime(b["time"])));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildDaySelector(),
        const SizedBox(height: 16),
        Expanded(child: _buildTimeline()),
      ],
    );
  }

  Widget _buildDaySelector() {
    final today = DateTime.now();
    final days = List.generate(7, (i) => today.add(Duration(days: i)));

    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        itemBuilder: (_, i) {
          final date = days[i];
          final selected = _isSameDay(date, selectedDate);
          return GestureDetector(
            onTap: () => setState(() => selectedDate = date),
            child: Container(
              width: 60,
              margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
              decoration: BoxDecoration(
                color: selected ? Colors.blue : Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "${date.day}",
                    style: TextStyle(
                      fontSize: 20,
                      color: selected ? Colors.white : Colors.black,
                    ),
                  ),
                  Text(
                    _dayLabel(date),
                    style: TextStyle(
                      color: selected ? Colors.white70 : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimeline() {
    if (allScheduledTasks.isEmpty) {
      return Center(child: Text("No scheduled tasks"));
    }

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: allScheduledTasks.length,
      separatorBuilder: (_, __) => SizedBox(height: 12),
      itemBuilder: (_, i) {
        final task = allScheduledTasks[i];
        final isMoment = task.containsKey("location");

        final time = task["time"] ?? "Time?";
        final duration = task["duration"] ?? (isMoment ? null : 15);
        final label = task["title"] ?? "Untitled";

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isMoment ? AppData.instance.colours['Moments']!['task']! : AppData.instance.colours['Flows']!['task']!,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "$time${duration != null ? " • $duration min" : ""}${isMoment && task["location"] != null ? " • ${task["location"]}" : ""}",
                style: TextStyle(color: Colors.grey[700]),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDate(DateTime d) =>
      "${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _dayLabel(DateTime d) {
    return ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"][d.weekday % 7];
  }

  DateTime _parseTime(String? time) {
    if (time == null) return DateTime(0);
    try {
      final now = DateTime.now();
      final t = TimeOfDay(
        hour: int.parse(time.split(":")[0]),
        minute: int.parse(time.split(":")[1].split(" ")[0]),
      );
      return DateTime(now.year, now.month, now.day, t.hour, t.minute);
    } catch (_) {
      return DateTime(0);
    }
  }
}
