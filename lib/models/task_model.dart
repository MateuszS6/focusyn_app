import 'package:focusyn_app/constants/keys.dart';
import 'package:intl/intl.dart';

class Task {
  final String id;
  final String text;
  final int priority;
  final int brainPoints;
  final String list;
  final String? date;
  final String? time;
  final int? duration;
  final String? location;
  final String? repeat;
  final List<String> history;
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
    List<String>? history,
    DateTime? createdAt,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
       history = history ?? [],
       createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      Keys.id: id,
      Keys.text: text,
      Keys.priority: priority,
      Keys.brainPoints: brainPoints,
      Keys.list: list,
      if (date != null) Keys.date: date,
      if (time != null) Keys.time: time,
      if (duration != null) Keys.duration: duration,
      if (location != null) Keys.location: location,
      if (repeat != null) Keys.repeat: repeat,
      Keys.history: history,
      Keys.createdAt: createdAt.toIso8601String(),
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map[Keys.id]?.toString() ?? '',
      text: map[Keys.text]?.toString() ?? '',
      priority: int.tryParse(map[Keys.priority]?.toString() ?? '') ?? 1,
      brainPoints: int.tryParse(map[Keys.brainPoints]?.toString() ?? '') ?? 0,
      list: map[Keys.list]?.toString() ?? 'All',
      date: map[Keys.date]?.toString(),
      time: map[Keys.time]?.toString(),
      duration: int.tryParse(map[Keys.duration]?.toString() ?? '') ?? 15,
      location: map[Keys.location]?.toString(),
      repeat: map[Keys.repeat]?.toString() ?? 'Repeat?',
      history:
          (map[Keys.history] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      createdAt: DateTime.parse(
        map[Keys.createdAt]?.toString() ?? DateTime.now().toIso8601String(),
      ),
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

  static String formatDate(String? date) {
    if (date == null) return '';

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
}
