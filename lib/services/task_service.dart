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
                    id: item['id'],
                    text: item['text'],
                    priority: item['priority'] ?? 1,
                    brainPoints: item['brainPoints'] ?? 0,
                    list: item['list'] ?? 'All',
                    date: item['date'],
                    time: item['time'],
                    duration: item['duration'],
                    location: item['location'],
                    repeat: item['repeat'],
                    createdAt: DateTime.parse(item['createdAt']),
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
                  'id': task.id,
                  'text': task.text,
                  'priority': task.priority,
                  'brainPoints': task.brainPoints,
                  'list': task.list,
                  'date': task.date,
                  'time': task.time,
                  'duration': task.duration,
                  'location': task.location,
                  'repeat': task.repeat,
                  'createdAt': task.createdAt.toIso8601String(),
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
