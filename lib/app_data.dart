class AppData {
  static final AppData instance = AppData._internal();
  AppData._internal();

  final Map<String, List<Map<String, dynamic>>> tasks = {
    "Actions": [
      {"title": "Complete Focusyn App", "priority": 1, "brainPoints": 10, "tag": "Work", "createdAt": DateTime.now().toIso8601String()},
      {"title": "Buy Groceries", "priority": 2, "brainPoints": 5, "tag": "Home", "createdAt": DateTime.now().toIso8601String()},
      {"title": "Call Mom", "priority": 3, "brainPoints": 3, "tag": "Home", "createdAt": DateTime.now().toIso8601String()},
      {"title": "Read a Book", "priority": 2, "brainPoints": 5, "createdAt": DateTime.now().toIso8601String()},
      {"title": "Go for a Run", "priority": 3, "brainPoints": 3, "createdAt": DateTime.now().toIso8601String()},
    ],
    "Flows": [
      {"title": "Morning Routine", "priority": 1, "brainPoints": 10, "tag": "Home", "createdAt": DateTime.now().toIso8601String()},
      {"title": "Evening Routine", "priority": 2, "brainPoints": 8, "tag": "Home", "createdAt": DateTime.now().toIso8601String()},
      {"title": "Workout Routine", "priority": 2, "brainPoints": 8, "tag": "Health", "createdAt": DateTime.now().toIso8601String()},
      {"title": "Weekly Review", "priority": 3, "brainPoints": 5, "createdAt": DateTime.now().toIso8601String()},
    ],
    "Moments": [
      {"title": "Birthday Party", "priority": 1, "brainPoints": 10, "tag": "Home", "createdAt": DateTime.now().toIso8601String()},
      {"title": "Meeting with Friends", "priority": 2, "brainPoints": 8, "tag": "School", "createdAt": DateTime.now().toIso8601String()},
      {"title": "Doctor's Appointment", "priority": 3, "brainPoints": 5, "tag": "Health", "createdAt": DateTime.now().toIso8601String()},
    ],
    "Thoughts": [
      {"text": "I should start reading more books", "createdAt": DateTime.now().toIso8601String()},
      {"text": "I need to call my parents more often", "createdAt": DateTime.now().toIso8601String()},
      {"text": "I should start working out", "createdAt": DateTime.now().toIso8601String()},
    ],
  };

  final Map<String, List<String>> filters = {
    'Actions': ['All', 'Home', 'Errands', 'Study'],
    'Flows': ['All', 'Morning', 'Evening', 'Wellness'],
    'Moments': ['All', 'Events', 'Appointments'],
    'Thoughts': ['All', 'Ideas', 'Journal'],
  };

  final Map<String, Set<String>> hiddenFilters = {
    'Actions': {},
    'Flows': {},
    'Moments': {},
    'Thoughts': {},
  };
}
