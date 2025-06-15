import 'package:focusyn_app/services/brain_service.dart';
import 'package:focusyn_app/services/filter_service.dart';
import 'package:focusyn_app/services/history_service.dart';
import 'package:focusyn_app/services/setting_service.dart';
import 'package:focusyn_app/services/task_service.dart';

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
    TaskService.initTasks();
    FilterService.initFilters();
    BrainService.initPoints();
    HistoryService.initHistory();
    SettingService.initSettings();
  }
}
