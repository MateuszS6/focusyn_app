import 'package:focusyn_app/data/keys.dart';
import 'package:hive/hive.dart';

class BrainPointsService {
  static final _box = Hive.box(Keys.homeBox);
  static const _pointsKey = Keys.brainPoints;
  static const _dateKey = 'lastReset';
  static const int _maxPoints = 100;

  static int getPoints() {
    _checkReset();
    return _box.get(_pointsKey, defaultValue: _maxPoints);
  }

  static void setPoints(int value) {
    _box.put(_pointsKey, value.clamp(0, _maxPoints));
  }

  static void addPoints(int value) {
    _checkReset();
    final current = getPoints();
    setPoints(current + value);
  }

  static void subtractPoints(int value) {
    _checkReset();
    final current = getPoints();
    setPoints(current - value);
  }

  static void reset() {
    _box.put(_pointsKey, _maxPoints);
    _box.put(_dateKey, DateTime.now().toIso8601String());
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
