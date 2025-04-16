import 'package:focusyn_app/constants/keys.dart';
import 'package:focusyn_app/services/cloud_sync_service.dart';
import 'package:hive/hive.dart';

class TaskService {
  static final _taskBox = Hive.box(Keys.taskBox);

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
      print('DEBUG: Starting cloud sync for tasks...');
      await CloudSyncService.uploadTasks(_taskBox);
      print('DEBUG: Cloud sync for tasks completed successfully');
    } catch (e) {
      print('DEBUG: Error in updateTasks: $e');
      rethrow;
    }
  }
}
