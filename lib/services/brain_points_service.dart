import 'package:focusyn_app/constants/keys.dart';
import 'package:focusyn_app/services/cloud_sync_service.dart';
import 'package:hive/hive.dart';

class BrainPointsService {
  static final _box = Hive.box(Keys.brainBox);
  static const _pointsKey = Keys.brainPoints;
  static const _dateKey = 'lastReset';
  static const int _minPoints = 0;
  static const int _maxPoints = 100;

  static int getPoints() {
    _checkReset();
    return _box.get(_pointsKey, defaultValue: _maxPoints);
  }

  static Future<void> setPoints(int value) async {
    _box.put(_pointsKey, value.clamp(_minPoints, _maxPoints));
    await CloudSyncService.uploadBrainPoints(_box);
  }

  static Future<void> addPoints(int value) async {
    _checkReset();
    final current = getPoints();
    final newPoints = current + value;
    if (newPoints > _maxPoints) {
      await setPoints(_maxPoints);
    } else {
      await setPoints(newPoints);
    }
  }

  static Future<void> subtractPoints(int value) async {
    _checkReset();
    final current = getPoints();
    final newPoints = current - value;
    if (newPoints < _minPoints) {
      await setPoints(_minPoints);
    } else {
      await setPoints(newPoints);
    }
  }

  static Future<void> reset() async {
    _box.put(_pointsKey, _maxPoints);
    _box.put(_dateKey, DateTime.now().toIso8601String());
    await CloudSyncService.uploadBrainPoints(_box);
  }

  static void _checkReset() {
    final lastReset = _box.get(_dateKey) as String?;
    if (lastReset == null) {
      reset();
      return;
    }

    final lastResetDate = DateTime.parse(lastReset);
    final now = DateTime.now();
    if (now.year > lastResetDate.year ||
        now.month > lastResetDate.month ||
        now.day > lastResetDate.day) {
      reset();
    }
  }
}
