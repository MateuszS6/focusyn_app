import 'package:focusyn_app/constants/keys.dart';
import 'package:hive/hive.dart';

class AppDataInit {
  static Future<void> run() async {
    final taskBox = Hive.box(Keys.taskBox);
    final filterBox = Hive.box(Keys.filterBox);
    final brainBox = Hive.box(Keys.brainBox);

    // Ensure boxes are initialized with empty lists if they don't exist
    if (!taskBox.containsKey(Keys.actions)) {
      taskBox.put(Keys.actions, []);
    }
    if (!taskBox.containsKey(Keys.flows)) {
      taskBox.put(Keys.flows, []);
    }
    if (!taskBox.containsKey(Keys.moments)) {
      taskBox.put(Keys.moments, []);
    }
    if (!taskBox.containsKey(Keys.thoughts)) {
      taskBox.put(Keys.thoughts, []);
    }

    // Ensure filter categories exist
    if (!filterBox.containsKey(Keys.actions)) {
      filterBox.put(Keys.actions, [Keys.all]);
    }
    if (!filterBox.containsKey(Keys.flows)) {
      filterBox.put(Keys.flows, [Keys.all]);
    }
    if (!filterBox.containsKey(Keys.moments)) {
      filterBox.put(Keys.moments, [Keys.all]);
    }
    if (!filterBox.containsKey(Keys.thoughts)) {
      filterBox.put(Keys.thoughts, [Keys.all]);
    }

    // Ensure brain points are initialized
    if (!brainBox.containsKey(Keys.brainPoints)) {
      brainBox.put(Keys.brainPoints, 100);
    }
    if (!brainBox.containsKey('lastReset')) {
      brainBox.put('lastReset', DateTime.now().toIso8601String());
    }
  }
}
