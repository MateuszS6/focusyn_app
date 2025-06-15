import 'package:flutter/material.dart';
import 'package:focusyn_app/constants/keys.dart';
import 'package:hive/hive.dart';
import 'package:focusyn_app/models/task_model.dart';

/// Handles the initialization of application data structures and default values.
/// This class ensures that all required Hive boxes are properly initialized
/// with default values and empty collections where needed.
class AppDataInit {
  /// Initializes all application data structures with default values.
  /// This method:
  /// 1. Initializes task lists for each focus category
  /// 2. Sets up filter categories
  /// 3. Initializes brain points and reset tracking
  /// 4. Configures notification settings
  /// 5. Sets up flow history tracking
  static Future<void> run() async {
    final taskBox = Hive.box<List>(Keys.taskBox);
    final filterBox = Hive.box(Keys.filterBox);
    final brainBox = Hive.box(Keys.brainBox);
    final historyBox = Hive.box(Keys.historyBox);
    final settingBox = Hive.box(Keys.settingBox);

    // Initialize task lists for each focus category
    if (!taskBox.containsKey(Keys.actions)) {
      taskBox.put(Keys.actions, <Task>[]);
    }
    if (!taskBox.containsKey(Keys.flows)) {
      taskBox.put(Keys.flows, <Task>[]);
    }
    if (!taskBox.containsKey(Keys.moments)) {
      taskBox.put(Keys.moments, <Task>[]);
    }
    if (!taskBox.containsKey(Keys.thoughts)) {
      taskBox.put(Keys.thoughts, <Task>[]);
    }

    // Initialize filter categories with default 'All' option
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

    // Initialize brain points system
    if (!brainBox.containsKey(Keys.brainPoints)) {
      brainBox.put(Keys.brainPoints, 100);
    }
    if (!brainBox.containsKey('lastReset')) {
      brainBox.put('lastReset', DateTime.now().toIso8601String());
    }

    // Initialize flow history tracking
    if (!historyBox.containsKey('flow_history')) {
      historyBox.put('flow_history', <String>[]);
    }

    // Initialize notification settings with default values
    if (!settingBox.containsKey(Keys.navBarText)) {
      settingBox.put(
        Keys.navBarText,
        NavigationDestinationLabelBehavior.alwaysShow.name,
      );
    }
    if (!settingBox.containsKey(Keys.notisEnabled)) {
      settingBox.put(Keys.notisEnabled, false);
    }
    if (!settingBox.containsKey(Keys.notiHour)) {
      settingBox.put(Keys.notiHour, 9);
    }
    if (!settingBox.containsKey(Keys.notiMinute)) {
      settingBox.put(Keys.notiMinute, 0);
    }
  }
}
