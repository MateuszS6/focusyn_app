import 'package:flutter/material.dart';
import 'package:focusyn_app/constants/keys.dart';
import 'package:hive/hive.dart';

class TaskService {
  static final TaskService instance = TaskService._internal();
  TaskService._internal();

  final _taskBox = Hive.box(Keys.taskBox);
  final _filterBox = Hive.box(Keys.filterBox);

  Map<String, List<Map<String, dynamic>>> get tasks {
    final result = <String, List<Map<String, dynamic>>>{};

    for (var key in _taskBox.keys) {
      final rawList = _taskBox.get(key);
      if (rawList is List) {
        result[key] =
            rawList.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
    }
    return result;
  }

  Map<String, List<String>> get filters {
    final result = <String, List<String>>{};

    for (var key in _filterBox.keys) {
      if (key == 'hidden') continue;
      final rawList = _filterBox.get(key);
      if (rawList is List) {
        result[key] = List<String>.from(rawList);
      }
    }
    return result;
  }

  void updateTasks(String category, List<Map<String, dynamic>> list) {
    _taskBox.put(category, list);
  }

  void updateFilters(String category, List<String> list) {
    _filterBox.put(category, list);
  }

  // You can keep this in memory
  final Map<String, Map<String, Color?>> colours = {
    Keys.actions: {'main': Colors.purple, 'task': Colors.purple[50]},
    Keys.flows: {'main': Colors.lightGreen, 'task': Colors.green[50]},
    Keys.moments: {'main': Colors.red, 'task': Colors.red[50]},
    Keys.thoughts: {'main': Colors.orange, 'task': Colors.orange[50]},
  };
}
