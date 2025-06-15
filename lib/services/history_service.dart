import 'package:focusyn_app/constants/keys.dart';
import 'package:focusyn_app/services/cloud_service.dart';
import 'package:hive/hive.dart';

/// A service class for managing flow completion history.
/// This service provides:
/// - Local storage of flow completion dates using Hive
/// - Methods to track and retrieve flow completion history
/// - Cloud synchronization of history data
class HistoryService {
  static final _box = Hive.box(Keys.historyBox);

  /// Key used to store flow history in Hive box
  static const String _historyKey = 'flow_history';

  /// Retrieves all flow completion dates from storage.
  /// This method:
  /// - Fetches history data from local storage
  /// - Converts stored date strings to DateTime objects
  /// - Returns an empty list if no history exists
  ///
  /// Returns a list of DateTime objects representing completion dates
  static List<DateTime> getCompletions() {
    final history =
        _box.get(_historyKey, defaultValue: <String>[]) as List<dynamic>;

    return history.map((date) => DateTime.parse(date.toString())).toList();
  }

  /// Records a new flow completion date.
  /// This method:
  /// - Adds the new date to existing history
  /// - Saves the updated history to local storage
  /// - Triggers cloud synchronization
  ///
  /// [date] - The date of flow completion to record
  ///
  /// Throws an exception if the update or sync fails
  static Future<void> addCompletion(DateTime date) async {
    final history = List<String>.from(
      _box.get(_historyKey, defaultValue: <String>[]),
    );

    // Add the new date
    history.add(date.toIso8601String());

    // Save to Hive
    await _box.put(_historyKey, history);

    // Sync to cloud
    await CloudService.uploadFlowHistory();
  }

  /// Removes all flow completion history.
  /// This method:
  /// - Clears all stored completion dates
  /// - Updates local storage with an empty list
  static void clearLocalHistory() {
    _box.put(_historyKey, <String>[]);
  }

  // Initializes flow history tracking
  static void initHistory() {
    if (!_box.containsKey('flow_history')) {
      _box.put('flow_history', <String>[]);
    }
  }
}
