import 'package:hive/hive.dart';

class AppDataInitializer {
  static Future<void> run() async {
    final taskBox = Hive.box('taskBox');
    final filterBox = Hive.box('filterBox');

    // Only run if empty
    if (taskBox.isEmpty) {
      taskBox.putAll({
        'Actions': [
          {
            "title": "Complete Focusyn App",
            "priority": 1,
            "brainPoints": 10,
            "tag": "Work",
            "createdAt": DateTime.now().toIso8601String(),
          },
        ],
        'Flows': [
          {
            "title": "Morning Routine",
            "date": "2025-03-30",
            "time": "07:30",
            "duration": 15,
            "repeat": "Daily",
            "brainPoints": 10,
            "tag": "Morning",
            "createdAt": DateTime.now().toIso8601String(),
          },
        ],
        'Moments': [
          {
            "title": "Doctor’s Appointment",
            "date": "2025-04-03",
            "time": "10:30",
            "duration": 30,
            "location": "Clinic",
            "tag": "Health",
            "createdAt": DateTime.now().toIso8601String(),
          },
        ],
        'Thoughts': [
          {
            "text": "I should start reading more books",
            "createdAt": DateTime.now().toIso8601String(),
          }
        ],
      });
    }

    if (filterBox.isEmpty) {
      filterBox.putAll({
        'Actions': ['All', 'Home', 'Errands', 'Work'],
        'Flows': ['All', 'Morning', 'Wellness'],
        'Moments': ['All', 'Appointments', 'Social'],
        'Thoughts': ['All', 'Ideas', 'Journal'],
        'hidden': {
          'Actions': [],
          'Flows': [],
          'Moments': [],
          'Thoughts': [],
        },
      });
    }
  }
}
