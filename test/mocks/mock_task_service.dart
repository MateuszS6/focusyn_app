import 'package:focusyn_app/constants/keys.dart';
import 'package:focusyn_app/models/task_model.dart';

class MockTaskService {
  static final Map<String, List<Task>> _tasks = {
    Keys.actions: [],
    Keys.flows: [],
    Keys.moments: [],
    Keys.thoughts: [],
  };

  static Map<String, List<Task>> get tasks => _tasks;

  static Future<void> updateTasks(String category, List<Task> list) async {
    _tasks[category] = list;
  }
}
