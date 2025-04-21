import 'package:intl/intl.dart';
import 'package:hive/hive.dart';

part 'task_model.g.dart';

@HiveType(typeId: 0)
class Task {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String text;

  @HiveField(2)
  final int priority;

  @HiveField(3)
  final int brainPoints;

  @HiveField(4)
  final String list;

  @HiveField(5)
  final String? date;

  @HiveField(6)
  final String? time;

  @HiveField(7)
  final int? duration;

  @HiveField(8)
  final String? repeat;

  @HiveField(9)
  final String? location;

  @HiveField(10)
  final DateTime createdAt;

  Task({
    String? id,
    required this.text,
    this.priority = 1,
    this.brainPoints = 0,
    this.list = 'All',
    this.date = '',
    this.time = '',
    this.duration = 15,
    this.location = '',
    this.repeat = 'Repeat?',
    DateTime? createdAt,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
       createdAt = createdAt ?? DateTime.now();

  // Helper method to create a copy of a task with some fields updated
  Task copyWith({
    String? id,
    String? text,
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
      text: text ?? this.text,
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

  String formatDate() {
    if (date == null) return '';

    final inputDate = DateTime.tryParse(date!);
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
      return date!;
    }
  }

  bool isOverdue() {
    if (date == null || date!.isEmpty) return false;

    final taskDate = DateTime.parse(date!);
    final now = DateTime.now();

    // If time is specified, create a DateTime object with both date and time
    if (time != null && time!.isNotEmpty) {
      final timeParts = time!.split(':');
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
}
