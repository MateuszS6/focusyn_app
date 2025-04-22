import 'package:flutter/material.dart';
import 'package:focusyn_app/constants/theme_icons.dart';
import 'package:focusyn_app/pages/task_page.dart';
import 'package:focusyn_app/services/task_service.dart';
import 'package:focusyn_app/constants/keys.dart';
import 'package:focusyn_app/models/task_model.dart';
import 'package:focusyn_app/utils/my_scroll_shadow.dart';

/// A page that displays a weekly planner view of scheduled tasks.
///
/// This page provides:
/// - A 7-day date selector
/// - Timeline view of scheduled tasks
/// - Visual distinction between flows and moments
/// - Task details including time, duration, and location
class PlannerPage extends StatefulWidget {
  const PlannerPage({super.key});

  @override
  State<PlannerPage> createState() => _PlannerPageState();
}

/// Manages the state of the planner page, including:
/// - Date selection
/// - Task filtering and sorting
/// - Timeline display
class _PlannerPageState extends State<PlannerPage> {
  /// The currently selected date in the planner
  DateTime selectedDate = DateTime.now();

  /// Gets all scheduled tasks for the selected date, sorted by time.
  ///
  /// Combines both flows and moments tasks, and sorts them chronologically.
  List<Task> get allScheduledTasks {
    final formattedDate = _formatDate(selectedDate);
    // Get flows scheduled for the selected date
    final flows =
        TaskService.tasks[Keys.flows]!
            .where((task) => task.date == formattedDate)
            .toList();

    // Get moments scheduled for the selected date
    final moments =
        TaskService.tasks[Keys.moments]!
            .where((task) => task.date == formattedDate)
            .toList();

    // Combine and sort by time
    return [...flows, ...moments]..sort(
      (a, b) => _parseTime(a.time ?? '').compareTo(_parseTime(b.time ?? '')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Planner', style: Theme.of(context).textTheme.displayLarge),
              const SizedBox(height: 24),
              _buildDaySelector(),
              const SizedBox(height: 24),
              Expanded(child: _buildTimeline()),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a horizontal scrollable list of days for date selection.
  ///
  /// Shows 7 days starting from today, with visual indication of the selected date.
  Widget _buildDaySelector() {
    final today = DateTime.now();
    final days = List.generate(7, (i) => today.add(Duration(days: i)));

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue.shade50, Colors.white],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: SizedBox(
        height: 80,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: days.length,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemBuilder: (_, i) {
            final date = days[i];
            final selected = _isSameDay(date, selectedDate);
            return GestureDetector(
              onTap: () => setState(() => selectedDate = date),
              child: Container(
                width: 56,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: selected ? Colors.blue : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "${date.day}",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: selected ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _dayLabel(date),
                      style: TextStyle(
                        fontSize: 13,
                        color: selected ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Builds a timeline view of scheduled tasks for the selected date.
  ///
  /// Shows an empty state if no tasks are scheduled, otherwise displays
  /// a scrollable list of tasks sorted by time.
  Widget _buildTimeline() {
    if (allScheduledTasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(ThemeIcons.noEvents, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              "No scheduled tasks",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return MyScrollShadow(
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemCount: allScheduledTasks.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) {
          final task = allScheduledTasks[i];
          // Determine if the task is a moment or flow
          final isMoment = TaskService.tasks[Keys.moments]!.any(
            (moment) =>
                moment.title == task.title &&
                moment.date == task.date &&
                moment.time == task.time,
          );
          final color = isMoment ? Colors.red : Colors.green;

          // Build a card for each scheduled task
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color.shade50, Colors.white],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(13),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => TaskPage(
                            category: isMoment ? Keys.moments : Keys.flows,
                          ),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: color.withAlpha(179),
                        child: Icon(
                          isMoment ? ThemeIcons.moments : ThemeIcons.flows,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (isMoment && task.location != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                task.location!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            task.time ?? '',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: color.shade700,
                            ),
                          ),
                          if (task.duration != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              "${task.duration} min",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Formats a DateTime object into a string in 'yyyy-MM-dd' format.
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Parses a time string in 'HH:mm' format into a DateTime object.
  ///
  /// Returns a DateTime object with the current date and the specified time.
  DateTime _parseTime(String time) {
    final parts = time.split(':');
    final now = DateTime.now();
    return DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }

  /// Checks if two DateTime objects represent the same day.
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Returns a short day label (e.g., 'Mon', 'Tue') for a given date.
  String _dayLabel(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }
}
