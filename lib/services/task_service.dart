import 'package:focusyn_app/constants/keys.dart';
import 'package:focusyn_app/services/cloud_sync_service.dart';
import 'package:hive/hive.dart';

class TaskService {
  static final _taskBox = Hive.box(Keys.taskBox);
  static final _filterBox = Hive.box(Keys.filterBox);
  static final _brainBox = Hive.box(Keys.brainBox);

  static Map<String, List<Map<String, dynamic>>> get tasks {
    final result = <String, List<Map<String, dynamic>>>{};

    for (var key in _taskBox.keys) {
      final rawList = _taskBox.get(key);
      if (rawList is List) {
        result[key] =
            rawList.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        print('DEBUG: Loaded ${result[key]!.length} tasks for category: $key');
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
        print(
          'DEBUG: Loaded ${result[key]!.length} filters for category: $key',
        );
      }
    }
    return result;
  }

  static Future<void> updateTasks(
    String category,
    List<Map<String, dynamic>> list,
  ) async {
    try {
      print('DEBUG: Updating tasks for category: $category');
      print('DEBUG: Current task count: ${list.length}');
      print(
        'DEBUG: Task details: ${list.map((t) => t[Keys.title]).join(', ')}',
      );

      // Update local storage
      await _taskBox.put(category, list);
      print('DEBUG: Local storage updated successfully');

      // Sync to cloud
      print('DEBUG: Starting cloud sync...');
      await CloudSyncService.uploadTasks(_taskBox, _filterBox, _brainBox);
      print('DEBUG: Cloud sync completed successfully');
    } catch (e) {
      print('DEBUG: Error in updateTasks: $e');
      rethrow;
    }
  }

  static Future<void> updateFilters(String category, List<String> list) async {
    try {
      print('DEBUG: Updating filters for category: $category');
      print('DEBUG: Current filter count: ${list.length}');
      print('DEBUG: Filter details: ${list.join(', ')}');

      await _filterBox.put(category, list);
      print('DEBUG: Local storage updated successfully');

      // Sync to cloud
      print('DEBUG: Starting cloud sync...');
      await CloudSyncService.uploadTasks(_taskBox, _filterBox, _brainBox);
      print('DEBUG: Cloud sync completed successfully');
    } catch (e) {
      print('DEBUG: Error in updateFilters: $e');
      rethrow;
    }
  }
}
