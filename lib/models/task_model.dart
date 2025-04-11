import 'package:focusyn_app/data/keys.dart';

class TaskModel {
  final String title;
  final int priority;
  final int brainPoints;
  final String tag;
  final String? text;
  final String? date;
  final String? time;
  final String? duration;
  final String? location;
  final String? repeat;
  final String? history;
  final DateTime createdAt;

  TaskModel({
    required this.title,
    this.priority = 1,
    this.brainPoints = 5,
    this.tag = Keys.all,
    this.text,
    this.date,
    this.time,
    this.duration,
    this.location,
    this.repeat,
    this.history,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      Keys.title: title,
      Keys.priority: priority,
      Keys.brainPoints: brainPoints,
      Keys.tag: tag,
      if (text != null) Keys.text: text,
      if (date != null) Keys.date: date,
      if (time != null) Keys.time: time,
      if (duration != null) Keys.duration: duration,
      if (location != null) Keys.location: location,
      if (repeat != null) Keys.repeat: repeat,
      if (history != null) Keys.history: history,
      Keys.createdAt: createdAt.toIso8601String(),
    };
  }

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      title: map[Keys.title] as String,
      priority: map[Keys.priority] as int? ?? 1,
      brainPoints: map[Keys.brainPoints] as int? ?? 5,
      tag: map[Keys.tag] as String? ?? Keys.all,
      text: map[Keys.text] as String?,
      date: map[Keys.date] as String?,
      time: map[Keys.time] as String?,
      duration: map[Keys.duration] as String?,
      location: map[Keys.location] as String?,
      repeat: map[Keys.repeat] as String?,
      history: map[Keys.history] as String?,
      createdAt: DateTime.parse(map[Keys.createdAt] as String),
    );
  }
}
