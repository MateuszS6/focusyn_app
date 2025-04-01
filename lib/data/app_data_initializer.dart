import 'package:focusyn_app/data/keys.dart';
import 'package:hive/hive.dart';

class AppDataInitializer {
  static Future<void> run() async {
    final taskBox = Hive.box(Keys.taskBox);
    final filterBox = Hive.box(Keys.filterBox);

    // Only run if empty
    if (taskBox.isEmpty) {
      taskBox.putAll({
        Keys.actions: [
          {
            Keys.title: "Complete Focusyn App",
            Keys.priority: 1,
            Keys.brainPoints: 10,
            Keys.tag: "Work",
            Keys.createdAt: DateTime.now().toIso8601String(),
          },
        ],
        Keys.flows: [
          {
            Keys.title: "Morning Routine",
            Keys.date: "2025-03-30",
            Keys.time: "07:30",
            Keys.duration: 15,
            Keys.repeat: "Daily",
            Keys.brainPoints: 10,
            Keys.history: [],
            Keys.tag: "Morning",
            Keys.createdAt: DateTime.now().toIso8601String(),
          },
        ],
        Keys.moments: [
          {
            Keys.title: "Doctor’s Appointment",
            Keys.date: "2025-04-03",
            Keys.time: "10:30",
            Keys.duration: 30,
            Keys. location: "Clinic",
            Keys.tag: "Health",
            Keys.createdAt: DateTime.now().toIso8601String(),
          },
        ],
        Keys.thoughts: [
          {
            Keys.text: "I should start reading more books",
            Keys.createdAt: DateTime.now().toIso8601String(),
          }
        ],
      });
    }

    if (filterBox.isEmpty) {
      filterBox.putAll({
        Keys.actions: [Keys.all, 'Home', 'Errands', 'Work'],
        Keys.flows: [Keys.all, 'Morning', 'Wellness'],
        Keys.moments: [Keys.all, 'Appointments', 'Social'],
        Keys.thoughts: [Keys.all, 'Ideas', 'Journal'],
        Keys.hidden: {
          Keys.actions: [],
          Keys.flows: [],
          Keys.moments: [],
          Keys.thoughts: [],
        },
      });
    }
  }
}
