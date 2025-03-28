class AppData {
  static final AppData instance = AppData._internal();
  AppData._internal();

  final Map<String, List<Map<String, dynamic>>> tasks = {
    "Actions": [
      {
        "title": "Complete Focusyn App",
        "priority": 1,
        "brainPoints": 10,
        "tag": "Work",
        "createdAt": DateTime.now().toIso8601String(),
      },
      {
        "title": "Buy Groceries",
        "priority": 2,
        "brainPoints": 5,
        "tag": "Home",
        "createdAt": DateTime.now().toIso8601String(),
      },
      {
        "title": "Call Mom",
        "priority": 3,
        "brainPoints": 3,
        "tag": "Home",
        "createdAt": DateTime.now().toIso8601String(),
      },
      {
        "title": "Read a Book",
        "priority": 2,
        "brainPoints": 5,
        "tag": "Personal",
        "createdAt": DateTime.now().toIso8601String(),
      },
      {
        "title": "Go for a Run",
        "priority": 3,
        "brainPoints": 3,
        "tag": "Health",
        "createdAt": DateTime.now().toIso8601String(),
      },
    ],
    "Flows": [
      {
        "title": "Morning Routine",
        "dueDate": "2025-03-30",
        "time": "07:30 AM",
        "repeat": "Daily",
        "tag": "Morning",
        "createdAt": DateTime.now().toIso8601String(),
      },
      {
        "title": "Evening Routine",
        "dueDate": "2025-03-30",
        "time": "09:00 PM",
        "repeat": "Daily",
        "tag": "Evening",
        "createdAt": DateTime.now().toIso8601String(),
      },
      {
        "title": "Workout Routine",
        "dueDate": "2025-04-01",
        "time": "06:00 PM",
        "repeat": "Weekly",
        "tag": "Health",
        "createdAt": DateTime.now().toIso8601String(),
      },
      {
        "title": "Weekly Review",
        "dueDate": "2025-03-31",
        "time": "05:00 PM",
        "repeat": "Weekly",
        "tag": "Work",
        "createdAt": DateTime.now().toIso8601String(),
      },
    ],
    "Moments": [
      {
        "title": "Birthday Party",
        "date": "2025-04-05",
        "time": "6:00 PM",
        "location": "John’s House",
        "tag": "Home",
        "createdAt": DateTime.now().toIso8601String(),
      },
      {
        "title": "Meeting with Friends",
        "date": "2025-04-07",
        "time": "3:00 PM",
        "location": "Café Downtown",
        "tag": "Social",
        "createdAt": DateTime.now().toIso8601String(),
      },
      {
        "title": "Doctor’s Appointment",
        "date": "2025-04-03",
        "time": "10:30 AM",
        "location": "Health Centre",
        "tag": "Health",
        "createdAt": DateTime.now().toIso8601String(),
      },
    ],
    "Thoughts": [
      {
        "text": "I should start reading more books.",
        "createdAt": DateTime.now().toIso8601String(),
      },
      {
        "text": "Maybe I’ll build a habit tracker after this.",
        "createdAt": DateTime.now().toIso8601String(),
      },
      {
        "text": "Think about how to make morning routines easier.",
        "createdAt": DateTime.now().toIso8601String(),
      },
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
