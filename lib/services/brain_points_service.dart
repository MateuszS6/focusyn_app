import 'package:focusyn_app/constants/keys.dart';
import 'package:focusyn_app/services/cloud_sync_service.dart';
import 'package:hive/hive.dart';

/// A service class for managing brain points, a gamification feature.
/// This service provides:
/// - Daily tracking and reset of brain points
/// - Methods to add, subtract, and retrieve points
/// - Cloud synchronization of points data
/// - Enforces minimum and maximum point limits
class BrainPointsService {
  /// Hive box for storing brain points data
  static final _box = Hive.box(Keys.brainBox);

  /// Key for storing current points value
  static const _pointsKey = Keys.brainPoints;

  /// Key for storing last reset date
  static const _dateKey = 'lastReset';

  /// Minimum allowed points value
  static const int _minPoints = 0;

  /// Maximum allowed points value
  static const int _maxPoints = 100;

  /// Gets the current brain points value.
  /// This method:
  /// - Checks if points need to be reset based on date
  /// - Returns the current points value
  /// - Returns maximum points if no value is stored
  static int getPoints() {
    _checkReset();
    return _box.get(_pointsKey, defaultValue: _maxPoints);
  }

  /// Sets the brain points to a specific value.
  /// This method:
  /// - Clamps the value between minimum and maximum limits
  /// - Updates local storage
  /// - Triggers cloud synchronization
  ///
  /// [value] - The new points value to set
  ///
  /// Throws an exception if the update or sync fails
  static Future<void> setPoints(int value) async {
    _box.put(_pointsKey, value.clamp(_minPoints, _maxPoints));
    await CloudSyncService.uploadBrainPoints(_box);
  }

  /// Adds points to the current total.
  /// This method:
  /// - Checks if points need to be reset based on date
  /// - Adds the specified value to current points
  /// - Ensures the result does not exceed maximum points
  ///
  /// [value] - The number of points to add
  ///
  /// Throws an exception if the update or sync fails
  static Future<void> addPoints(int value) async {
    _checkReset();
    final current = getPoints();
    final newPoints = current + value;

    // Clamp the points to the maximum value
    if (newPoints > _maxPoints) {
      await setPoints(_maxPoints);
    } else {
      await setPoints(newPoints);
    }
  }

  /// Subtracts points from the current total.
  /// This method:
  /// - Checks if points need to be reset based on date
  /// - Subtracts the specified value from current points
  /// - Ensures the result does not go below minimum points
  ///
  /// [value] - The number of points to subtract
  ///
  /// Throws an exception if the update or sync fails
  static Future<void> subtractPoints(int value) async {
    _checkReset();
    final current = getPoints();
    final newPoints = current - value;

    // Clamp the points to the minimum value
    if (newPoints < _minPoints) {
      await setPoints(_minPoints);
    } else {
      await setPoints(newPoints);
    }
  }

  /// Resets brain points to maximum value.
  /// This method:
  /// - Sets points to maximum value
  /// - Updates the last reset date
  /// - Triggers cloud synchronization
  ///
  /// Throws an exception if the update or sync fails
  static Future<void> reset() async {
    _box.put(_pointsKey, _maxPoints);
    _box.put(_dateKey, DateTime.now().toIso8601String());
    await CloudSyncService.uploadBrainPoints(_box);
  }

  /// Checks if points need to be reset based on date.
  /// This method:
  /// - Compares current date with last reset date
  /// - Resets points if a new day has started
  /// - Initializes points if no reset date exists
  static void _checkReset() {
    // Initialize points if no reset date exists
    final lastReset = _box.get(_dateKey) as String?;
    if (lastReset == null) {
      reset();
      return;
    }

    // Check if a new day has started
    final lastResetDate = DateTime.parse(lastReset);
    final now = DateTime.now();
    if (now.year > lastResetDate.year ||
        now.month > lastResetDate.month ||
        now.day > lastResetDate.day) {
      reset();
    }
  }
}
