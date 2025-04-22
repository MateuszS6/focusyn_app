import 'package:focusyn_app/constants/keys.dart';
import 'package:focusyn_app/services/cloud_sync_service.dart';
import 'package:hive/hive.dart';

/// A service class for managing task filtering preferences.
/// This service provides:
/// - Local storage of filter settings using Hive
/// - Methods to retrieve and update filter configurations
/// - Cloud synchronization of filter data
class FilterService {
  /// Hive box for storing filter lists
  static final _filterBox = Hive.box(Keys.filterBox);

  /// Gets all filters organized by category.
  /// This getter:
  /// - Retrieves filters from local storage
  /// - Converts raw storage data to string lists
  /// - Organizes filters by their category
  /// - Handles missing or invalid data gracefully
  static Map<String, List<String>> get filters {
    final result = <String, List<String>>{};
    for (var key in _filterBox.keys) {
      final rawList = _filterBox.get(key);
      if (rawList is List) {
        result[key] = List<String>.from(rawList);
      }
    }
    return result;
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
      await _filterBox.put(category, list);
      // Sync to cloud
      await CloudSyncService.uploadFilters(_filterBox);
    } catch (e) {
      // Rethrow the exception to be handled by the caller
      rethrow;
    }
  }
}
