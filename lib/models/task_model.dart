import 'package:intl/intl.dart';
import 'package:hive/hive.dart';

part 'task_model.g.dart';

/// Represents a task in the Focusyn application.
/// This model is used to store and manage task data, including its properties
/// and helper methods for task manipulation.
///
/// The class is annotated with Hive for local storage persistence.
@HiveType(typeId: 0)
class Task {
  /// Unique identifier for the task
  @HiveField(0)
  final String id;

  /// Title or description of the task
  @HiveField(1)
  final String title;

  /// Priority level of the task (1-4)
  /// - 1: Urgent, Important
  /// - 2: Not Urgent, Important
  /// - 3: Urgent, Not Important
  /// - 4: Not Urgent, Not Important
  @HiveField(2)
  final int? priority;

  /// Points awarded for completing the task
  @HiveField(3)
  final int? brainPoints;

  /// Category or list the task belongs to
  @HiveField(4)
  final String list;

  /// Due date of the task in ISO 8601 format
  @HiveField(5)
  final String? date;

  /// Time of the task in 24-hour format (HH:mm)
  @HiveField(6)
  final String? time;

  /// Duration of the task in minutes
  @HiveField(7)
  final int? duration;

  /// Repeat pattern for recurring tasks
  @HiveField(8)
  final String? repeat;

  /// Location or venue for the task
  @HiveField(9)
  final String? location;

  /// Timestamp when the task was created
  @HiveField(10)
  final DateTime createdAt;

  /// Creates a new Task instance.
  ///
  /// [id] - Optional unique identifier. If not provided, generates one based on timestamp.
  /// [title] - Required title of the task.
  /// [priority] - Optional priority level (1-4).
  /// [brainPoints] - Optional points awarded for completion.
  /// [list] - Category or list name. Defaults to 'All'.
  /// [date] - Optional due date in ISO 8601 format.
  /// [time] - Optional time in 24-hour format.
  /// [duration] - Optional duration in minutes.
  /// [location] - Optional location information.
  /// [repeat] - Optional repeat pattern.
  /// [createdAt] - Optional creation timestamp. Defaults to current time.
  Task({
    String? id,
    required this.title,
    this.priority,
    this.brainPoints,
    this.list = 'All',
    this.date,
    this.time,
    this.duration,
    this.location,
    this.repeat,
    DateTime? createdAt,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
       createdAt = createdAt ?? DateTime.now();

  /// Creates a copy of this task with the specified fields replaced with new values.
  ///
  /// All parameters are optional. If a parameter is not provided,
  /// the value from the original task is used.
  Task copyWith({
    String? id,
    String? title,
    int? priority,
    int? brainPoints,
    String? list,
    String? date,
    String? time,
    int? duration,
    String? location,
    String? repeat,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      priority: priority ?? this.priority,
      brainPoints: brainPoints ?? this.brainPoints,
      list: list ?? this.list,
      date: date ?? this.date,
      time: time ?? this.time,
      duration: duration ?? this.duration,
      location: location ?? this.location,
      repeat: repeat ?? this.repeat,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Returns a human-readable description of the priority level.
  ///
  /// [priority] - The priority level (1-4)
  /// Returns a string describing the priority (e.g., "Urgent, Important")
  static String getPriorityText(int priority) {
    switch (priority) {
      case 1:
        return 'Urgent, Important';
      case 2:
        return 'Not Urgent, Important';
      case 3:
        return 'Urgent, Not Important';
      case 4:
        return 'Not Urgent, Not Important';
      default:
        return 'Unknown Priority';
    }
  }

  /// Formats a date string into a more readable format based on its relation to the current date.
  ///
  /// [date] - The date string in ISO 8601 format
  /// Returns:
  /// - Day name (e.g., "Monday") if within 7 days
  /// - Month and day (e.g., "Apr 20") if within the same year
  /// - Original date string otherwise
  static String formatDate(String date) {
    final inputDate = DateTime.tryParse(date);
    if (inputDate == null) return '';

    final now = DateTime.now();
    final difference = inputDate.difference(now).inDays;

    if (difference >= 0 && difference < 7) {
      // If within 7 days from now
      return DateFormat.EEEE().format(inputDate); // e.g., "Monday"
    } else if (inputDate.year == now.year) {
      // If within the same year
      return DateFormat.MMMd().format(inputDate); // e.g., "Apr 20"
    } else {
      // Else, just return the input date
      return date;
    }
  }

  /// Determines if a task is overdue based on its date and time.
  ///
  /// [date] - The task's due date in ISO 8601 format
  /// [time] - Optional time in 24-hour format
  /// Returns true if the task's due date/time has passed
  static bool isOverdue(String date, String? time) {
    if (date.isEmpty) return false;

    final taskDate = DateTime.parse(date);
    final now = DateTime.now();

    // If time is specified, create a DateTime object with both date and time
    if (time != null && time.isNotEmpty) {
      final timeParts = time.split(':');
      if (timeParts.length == 2) {
        final hours = int.tryParse(timeParts[0]) ?? 0;
        final minutes = int.tryParse(timeParts[1]) ?? 0;
        final taskDateTime = DateTime(
          taskDate.year,
          taskDate.month,
          taskDate.day,
          hours,
          minutes,
        );
        return taskDateTime.isBefore(now);
      }
    }

    // If no time is specified, compare dates only
    final taskDateOnly = DateTime(taskDate.year, taskDate.month, taskDate.day);
    final nowDateOnly = DateTime(now.year, now.month, now.day);

    return taskDateOnly.isBefore(nowDateOnly);
  }

  /// Calculates the next occurrence date for a recurring task.
  ///
  /// [repeat] - The repeat pattern ('Daily', 'Weekly', 'Monthly')
  /// Returns the next date based on the repeat pattern
  static DateTime calculateNextDate(String repeat) {
    final now = DateTime.now();
    switch (repeat) {
      case 'Daily':
        return now.add(const Duration(days: 1));
      case 'Weekly':
        return now.add(const Duration(days: 7));
      case 'Monthly':
        return DateTime(now.year, now.month + 1, now.day);
      default:
        return now;
    }
  }
}
