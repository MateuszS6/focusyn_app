import 'package:focusyn_app/constants/keys.dart';
import 'package:focusyn_app/services/cloud_service.dart';
import 'package:hive/hive.dart';

/// A service class for managing flow completion history.
/// This service provides:
/// - Local storage of flow completion dates using Hive
/// - Methods to track and retrieve flow completion history
/// - Cloud synchronization of history data
class FlowService {
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
    final historyBox = Hive.box(Keys.historyBox);
    final history =
        historyBox.get(_historyKey, defaultValue: <String>[]) as List<dynamic>;

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
    final historyBox = Hive.box(Keys.historyBox);
    final history = List<String>.from(
      historyBox.get(_historyKey, defaultValue: <String>[]),
    );

    // Add the new date
    history.add(date.toIso8601String());

    // Save to Hive
    await historyBox.put(_historyKey, history);

    // Sync to cloud
    await CloudService.uploadFlowHistory(historyBox);
  }

  /// Removes all flow completion history.
  /// This method:
  /// - Clears all stored completion dates
  /// - Updates local storage with an empty list
  /// - Triggers cloud synchronization
  ///
  /// Throws an exception if the update or sync fails
  static Future<void> clearHistory() async {
    final historyBox = Hive.box(Keys.historyBox);
    await historyBox.put(_historyKey, <String>[]);
    await CloudService.uploadFlowHistory(historyBox);
  }
}
