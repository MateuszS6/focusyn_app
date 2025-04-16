import 'package:focusyn_app/constants/keys.dart';
import 'package:hive/hive.dart';

class TaskService {
  static final _taskBox = Hive.box(Keys.taskBox);
  static final _filterBox = Hive.box(Keys.filterBox);

  static Map<String, List<Map<String, dynamic>>> get tasks {
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

  static Map<String, List<String>> get filters {
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

  static void updateTasks(String category, List<Map<String, dynamic>> list) {
    _taskBox.put(category, list);
  }

  static void updateFilters(String category, List<String> list) {
    _filterBox.put(category, list);
  }
}
