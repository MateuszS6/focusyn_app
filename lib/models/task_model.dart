import 'package:focusyn_app/constants/keys.dart';

class Task {
  final String id;
  final String title;
  final int priority;
  final int brainPoints;
  final String list;
  final String? text;
  final String? date;
  final String? time;
  final String? duration;
  final String? location;
  final String? repeat;
  final List<String> history;
  final DateTime createdAt;

  Task({
    String? id,
    required this.title,
    this.priority = 1,
    this.brainPoints = 0,
    this.list = 'All',
    this.text,
    this.date,
    this.time,
    this.duration,
    this.location,
    this.repeat,
    List<String>? history,
    DateTime? createdAt,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
       history = history ?? [],
       createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      Keys.id: id,
      Keys.title: title,
      Keys.priority: priority,
      Keys.brainPoints: brainPoints,
      Keys.list: list,
      if (text != null) Keys.text: text,
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
      id: map[Keys.id] ?? '',
      title: map[Keys.title] ?? '',
      priority: map[Keys.priority] ?? 1,
      brainPoints: map[Keys.brainPoints] ?? 0,
      list: map[Keys.list] ?? 'All',
      text: map[Keys.text] as String?,
      date: map[Keys.date] as String?,
      time: map[Keys.time] as String?,
      duration: map[Keys.duration] as String?,
      location: map[Keys.location] as String?,
      repeat: map[Keys.repeat] as String?,
      history:
          (map[Keys.history] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      createdAt: DateTime.parse(map[Keys.createdAt] as String),
    );
  }
}
