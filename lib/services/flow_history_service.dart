import 'package:focusyn_app/constants/keys.dart';
import 'package:hive/hive.dart';

class FlowHistoryService {
  static const String _historyKey = 'flow_history';

  /// Get all flow completion dates
  static List<DateTime> getCompletions() {
    final historyBox = Hive.box(Keys.historyBox);
    final history =
        historyBox.get(_historyKey, defaultValue: <String>[]) as List<dynamic>;

    return history.map((date) => DateTime.parse(date.toString())).toList();
  }

  /// Add a completion date to the history
  static Future<void> addCompletion(DateTime date) async {
    final historyBox = Hive.box(Keys.historyBox);
    final history = List<String>.from(
      historyBox.get(_historyKey, defaultValue: <String>[]),
    );

    // Add the new date
    history.add(date.toIso8601String());

    // Save back to Hive
    await historyBox.put(_historyKey, history);
  }

  /// Clear all history
  static Future<void> clearHistory() async {
    final historyBox = Hive.box(Keys.historyBox);
    await historyBox.put(_historyKey, <String>[]);
  }
}
