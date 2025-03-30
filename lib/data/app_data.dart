import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class AppData {
  static final AppData instance = AppData._internal();
  AppData._internal();

  final _taskBox = Hive.box('tasksBox');
  final _filterBox = Hive.box('filtersBox');

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

  Map<String, Set<String>> get hiddenFilters {
    final hidden = _filterBox.get('hidden');
    if (hidden is Map) {
      return Map<String, Set<String>>.fromEntries(
        hidden.entries.map(
          (e) => MapEntry(e.key.toString(), Set<String>.from(e.value)),
        ),
      );
    }
    return {};
  }

  void updateTasks(String category, List<Map<String, dynamic>> list) {
    _taskBox.put(category, list);
  }

  void updateFilters(String category, List<String> list) {
    _filterBox.put(category, list);
  }

  void updateHidden(String category, Set<String> hidden) {
    final current = Map<String, dynamic>.from(_filterBox.get('hidden') ?? {});
    current[category] = hidden.toList();
    _filterBox.put('hidden', current);
  }

  // You can keep this in memory
  final Map<String, Map<String, Color?>> colours = {
    'Actions': {'main': Colors.purple, 'task': Colors.purple[50]},
    'Flows': {'main': Colors.lightGreen, 'task': Colors.green[50]},
    'Moments': {'main': Colors.red, 'task': Colors.red[50]},
    'Thoughts': {'main': Colors.orange, 'task': Colors.orange[50]},
  };
}
