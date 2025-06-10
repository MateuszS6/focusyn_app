import 'package:focusyn_app/constants/keys.dart';
import 'package:focusyn_app/services/cloud_service.dart';
import 'package:hive/hive.dart';

/// A service class for managing task filtering preferences.
/// This service provides:
/// - Local storage of filter settings using Hive
/// - Methods to retrieve and update filter configurations
/// - Cloud synchronization of filter data
class FilterService {
  /// Hive box for storing filter lists
  static final _box = Hive.box(Keys.filterBox);

  /// Gets all filters organized by category.
  /// This getter:
  /// - Retrieves filters from local storage
  /// - Converts raw storage data to string lists
  /// - Organizes filters by their category
  /// - Handles missing or invalid data gracefully
  static Map<String, List<String>> get filters {
    final result = <String, List<String>>{};
    for (var key in _box.keys) {
      final rawList = _box.get(key);
      if (rawList is List) {
        result[key] = List<String>.from(rawList);
      }
    }
    return result;
  }

  /// Initializes default filters for different task types
  static void initDefaultFilters() {
    _box.putAll({
      Keys.actions: [Keys.all, 'Home', 'Errands', 'Work'],
      Keys.flows: [Keys.all, 'Morning', 'Wellness'],
      Keys.moments: [Keys.all, 'Appointments', 'Social'],
      Keys.thoughts: [Keys.all, 'Ideas', 'Journal'],
    });
  }

  /// Updates the filters for a specific category.
  /// This method:
  /// - Updates local storage with new filter settings
  /// - Triggers cloud synchronization
  ///
  /// [category] - The category of filters to update
  /// [list] - The list of filter strings to store
  ///
  /// Throws an exception if the update or sync fails
  static Future<void> updateFilters(String category, List<String> list) async {
    try {
      // Update local storage
      await _box.put(category, list);
      // Sync to cloud
      await CloudService.uploadFilters();
    } catch (e) {
      // Rethrow the exception to be handled by the caller
      rethrow;
    }
  }
}
