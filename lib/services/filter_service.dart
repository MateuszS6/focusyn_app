import 'package:focusyn_app/constants/keys.dart';
import 'package:focusyn_app/services/cloud_sync_service.dart';
import 'package:hive/hive.dart';

class FilterService {
  static final _filterBox = Hive.box(Keys.filterBox);

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

  static Future<void> updateFilters(String category, List<String> list) async {
    try {
      // Update local storage
      await _filterBox.put(category, list);
      // Sync to cloud
      await CloudSyncService.uploadFilters(_filterBox);
    } catch (e) {
      rethrow;
    }
  }
}
