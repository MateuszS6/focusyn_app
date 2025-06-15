import 'package:focusyn_app/constants/keys.dart';
import 'package:focusyn_app/models/task_model.dart';
import 'package:focusyn_app/services/cloud_service.dart';
import 'package:hive/hive.dart';

/// A service class for managing task data persistence and synchronization.
/// This service provides:
/// - Local storage of tasks using Hive
/// - Task data conversion between models and storage format
/// - Cloud synchronization of task data
class TaskService {
  /// Hive box for storing task lists
  static final _box = Hive.box<List>(Keys.taskBox);

  /// Gets all tasks organized by category.
  /// This getter:
  /// - Retrieves tasks from local storage
  /// - Converts raw storage data to Task objects
  /// - Organizes tasks by their category
  /// - Handles missing or invalid data gracefully
  static Map<String, List<Task>> get tasks {
    final result = <String, List<Task>>{};
    for (var key in _box.keys) {
      final rawList = _box.get(key);
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

  /// Initializes example tasks for new users
  static void initExampleTasks() {
    _box.putAll({
      Keys.actions: [
        {
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'text': "Complete Focusyn App",
          'priority': 1,
          'brainPoints': 10,
          'list': "Work",
          'createdAt': DateTime.now().toIso8601String(),
        },
      ],
      Keys.flows: [
        {
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'text': "Morning Routine",
          'date': "2025-03-30",
          'time': "07:30",
          'duration': 15,
          'repeat': "Daily",
          'brainPoints': 10,
          'list': "Morning",
          'createdAt': DateTime.now().toIso8601String(),
        },
      ],
      Keys.moments: [
        {
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'text': "Doctor's Appointment",
          'date': "2025-04-03",
          'time': "10:30",
          'duration': 30,
          'location': "Clinic",
          'list': "Health",
          'createdAt': DateTime.now().toIso8601String(),
        },
      ],
      Keys.thoughts: [
        {
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'text': "I should start reading more books",
          'createdAt': DateTime.now().toIso8601String(),
        },
      ],
    });
  }

  /// Updates the tasks for a specific category.
  /// This method:
  /// - Converts Task objects to storage format
  /// - Updates local storage
  /// - Triggers cloud synchronization
  ///
  /// [category] - The category of tasks to update
  /// [list] - The list of tasks to store
  ///
  /// Throws an exception if the update or sync fails
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
      await _box.put(category, taskMaps);
      // Sync to cloud
      await CloudService.uploadTasks();
    } catch (e) {
      // Rethrow the exception to be handled by the caller
      rethrow;
    }
  }

  /// Clears all tasks from local storage and syncs to the cloud.
  static void clearLocalTasks() {
    _box.putAll({
      Keys.actions: [],
      Keys.flows: [],
      Keys.moments: [],
      Keys.thoughts: [],
    });
  }

  /// Initializes task categories with empty lists if not already set
  static void initTasks() {
    if (!_box.containsKey(Keys.actions)) {
      _box.put(Keys.actions, []);
    }
    if (!_box.containsKey(Keys.flows)) {
      _box.put(Keys.flows, []);
    }
    if (!_box.containsKey(Keys.moments)) {
      _box.put(Keys.moments, []);
    }
    if (!_box.containsKey(Keys.thoughts)) {
      _box.put(Keys.thoughts, []);
    }
  }
}
