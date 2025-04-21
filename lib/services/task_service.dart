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
                    id: item[Keys.id],
                    title: item[Keys.text],
                    priority: item[Keys.priority] ?? 1,
                    brainPoints: item[Keys.brainPoints] ?? 0,
                    list: item[Keys.list] ?? 'All',
                    date: item[Keys.date],
                    time: item[Keys.time],
                    duration: item[Keys.duration],
                    repeat: item[Keys.repeat],
                    location: item[Keys.location],
                    createdAt: DateTime.parse(item[Keys.createdAt]),
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
                  Keys.text: task.title,
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
