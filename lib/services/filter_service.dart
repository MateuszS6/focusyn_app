import 'package:focusyn_app/constants/keys.dart';
import 'package:focusyn_app/services/cloud_sync_service.dart';
import 'package:hive/hive.dart';

class FilterService {
  static final _filterBox = Hive.box(Keys.filterBox);

  static Map<String, List<String>> get filters {
    final result = <String, List<String>>{};

    for (var key in _filterBox.keys) {
      if (key == 'hidden') continue;
      final rawList = _filterBox.get(key);
      if (rawList is List) {
        result[key] = List<String>.from(rawList);
        print(
          'DEBUG: Loaded ${result[key]!.length} filters for category: $key',
        );
      }
    }
    return result;
  }

  static Future<void> updateFilters(String category, List<String> list) async {
    try {
      print('DEBUG: Updating filters for category: $category');
      print('DEBUG: Current filter count: ${list.length}');
      print('DEBUG: Filter details: ${list.join(', ')}');

      await _filterBox.put(category, list);
      print('DEBUG: Local storage updated successfully');

      // Sync to cloud
      print('DEBUG: Starting cloud sync for filters...');
      await CloudSyncService.uploadFilters(_filterBox);
      print('DEBUG: Cloud sync for filters completed successfully');
    } catch (e) {
      print('DEBUG: Error in updateFilters: $e');
      rethrow;
    }
  }
}
