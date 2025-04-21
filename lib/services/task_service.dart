import 'package:focusyn_app/constants/keys.dart';
import 'package:focusyn_app/models/task_model.dart';
import 'package:focusyn_app/services/cloud_sync_service.dart';
import 'package:hive/hive.dart';

class TaskService {
  static final _taskBox = Hive.box<List>(Keys.taskBox);

  static Map<String, List<Task>> get tasks {
    final result = <String, List<Task>>{};
    for (var key in _taskBox.keys) {
      final rawList = _taskBox.get(key);
      if (rawList is List) {
        // Convert each map in the list to a Task object
        result[key] =
            rawList
                .map(
                  (item) => Task(
                    id:
                        item[Keys.id]?.toString() ??
                        DateTime.now().millisecondsSinceEpoch.toString(),
                    title: item[Keys.title]?.toString() ?? 'Untitled Task',
                    priority: (item[Keys.priority] as num?)?.toInt(),
                    brainPoints: (item[Keys.brainPoints] as num?)?.toInt(),
                    list: item[Keys.list]?.toString() ?? 'All',
                    date: item[Keys.date]?.toString(),
                    time: item[Keys.time]?.toString(),
                    duration: (item[Keys.duration] as num?)?.toInt(),
                    repeat: item[Keys.repeat]?.toString(),
                    location: item[Keys.location]?.toString(),
                    createdAt:
                        item[Keys.createdAt] != null
                            ? DateTime.parse(item[Keys.createdAt].toString())
                            : DateTime.now(),
                  ),
                )
                .toList();
      }
    }
    return result;
  }

  static Future<void> updateTasks(String category, List<Task> list) async {
    try {
      // Convert Task objects to maps before storing
      final taskMaps =
          list
              .map(
                (task) => {
                  Keys.id: task.id,
                  Keys.title: task.title,
                  Keys.priority: task.priority,
                  Keys.brainPoints: task.brainPoints,
                  Keys.list: task.list,
                  Keys.date: task.date,
                  Keys.time: task.time,
                  Keys.duration: task.duration,
                  Keys.repeat: task.repeat,
                  Keys.location: task.location,
                  Keys.createdAt: task.createdAt.toIso8601String(),
                },
              )
              .toList();

      // Update local storage
      await _taskBox.put(category, taskMaps);
      // Sync to cloud
      await CloudSyncService.uploadTasks(_taskBox);
    } catch (e) {
      rethrow;
    }
  }
}
