import 'package:hive/hive.dart';

class BrainPointsService {
  static final _box = Hive.box('appBox');
  static const _pointsKey = 'brainPoints';
  static const _dateKey = 'lastReset';

  static int getPoints() {
    _checkReset();
    return _box.get(_pointsKey, defaultValue: 100);
  }

  static void setPoints(int value) {
    _box.put(_pointsKey, value);
  }

  static void add(int value) {
    _checkReset();
    final current = getPoints();
    _box.put(_pointsKey, current + value);
  }

  static void subtract(int value) {
    _checkReset();
    final current = getPoints();
    _box.put(_pointsKey, current - value);
  }

  static void reset() {
    _box.put(_pointsKey, 100);
    _box.put(_dateKey, DateTime.now().toIso8601String());
  }

  static void _checkReset() {
    final last = _box.get(_dateKey);
    final today = DateTime.now();
    if (last == null || !_isSameDay(DateTime.parse(last), today)) {
      reset();
    }
  }

  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
