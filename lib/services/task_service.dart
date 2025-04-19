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
      }
    }
    return result;
  }

  static Future<void> updateTasks(
    String category,
    List<Map<String, dynamic>> list,
  ) async {
    try {
      // Update local storage
      await _taskBox.put(category, list);
      // Sync to cloud
      await CloudSyncService.uploadTasks(_taskBox);
    } catch (e) {
      rethrow;
    }
  }
}
