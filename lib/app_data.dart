class AppData {
  static final AppData instance = AppData._internal();
  AppData._internal();

  /// A list of all the tasks in the app.
  /// It is a map of task types to a list of tasks.
  /// Each task is represented as a map with various attributes.
  /// The task types are:
  /// - Actions: Tasks that need to be done.
  /// - Flows: Tasks that are part of a routine or process.
  /// - Moments: Important events, appointments, or deadlines.
  /// - Thoughts: Ideas or notes that need to be remembered.
  final Map<String, List<Map<String, dynamic>>> tasks = {
    'Actions': [
      {
        'title': 'Complete Focusyn App',
        'priority': 1,
        'brainPoints': 10,
        'tag': 'Work',
        'createdAt': DateTime.now().toIso8601String(),
      },
      {
        'title': 'Buy Groceries',
        'priority': 2,
        'brainPoints': 5,
        'tag': 'Home',
        'createdAt': DateTime.now().toIso8601String(),
      },
      {
        'title': 'Call Mom',
        'priority': 3,
        'brainPoints': 3,
        'tag': 'Home',
        'createdAt': DateTime.now().toIso8601String(),
      },
      {
        'title': 'Read a Book',
        'priority': 2,
        'brainPoints': 5,
        'tag': 'Personal',
        'createdAt': DateTime.now().toIso8601String(),
      },
      {
        'title': 'Go for a Run',
        'priority': 3,
        'brainPoints': 3,
        'tag': 'Health',
        'createdAt': DateTime.now().toIso8601String(),
      },
    ],

    'Flows': [
      {
        'title': 'Morning Routine',
        'date': '30-03-2025',
        'time': '07:30 AM',
        'duration': 30,
        'repeat': 'Daily',
        'tag': 'Morning',
        'createdAt': DateTime.now().toIso8601String(),
      },
      {
        'title': 'Evening Routine',
        'date': '2025-03-30',
        'time': '09:00 PM',
        'duration': 30,
        'repeat': 'Daily',
        'tag': 'Evening',
        'createdAt': DateTime.now().toIso8601String(),
      },
      {
        'title': 'Workout Routine',
        'date': '01-04-2025',
        'time': '06:00 PM',
        'duration': 60,
        'repeat': 'Weekly',
        'tag': 'Health',
        'createdAt': DateTime.now().toIso8601String(),
      },
      {
        'title': 'Weekly Review',
        'date': '31-03-2025',
        'time': '05:00 PM',
        'duration': 60,
        'repeat': 'Weekly',
        'tag': 'Work',
        'createdAt': DateTime.now().toIso8601String(),
      },
    ],

    'Moments': [
      {
        'title': 'Birthday Party',
        'date': '05-04-2025',
        'time': '6:00 PM',
        'duration': 180,
        'location': 'John’s House',
        'tag': 'Home',
        'createdAt': DateTime.now().toIso8601String(),
      },
      {
        'title': 'Meeting with Friends',
        'date': '07-04-2025',
        'time': '3:00 PM',
        'duration': 120,
        'location': 'Café Downtown',
        'tag': 'Social',
        'createdAt': DateTime.now().toIso8601String(),
      },
      {
        'title': 'Doctor’s Appointment',
        'date': '03-04-2025',
        'time': '10:30 AM',
        'duration': 60,
        'location': 'Health Clinic',
        'tag': 'Health',
        'createdAt': DateTime.now().toIso8601String(),
      },
    ],

    'Thoughts': [
      {
        'text': 'I should start reading more books.',
        'createdAt': DateTime.now().toIso8601String(),
      },
      {
        'text': 'Maybe I’ll build a habit tracker after this.',
        'createdAt': DateTime.now().toIso8601String(),
      },
      {
        'text': 'Think about how to make morning routines easier.',
        'createdAt': DateTime.now().toIso8601String(),
      },
    ],
  };

  /// A list of all the tags used in the app to filter tasks by tag.
  /// It is a map of tag names to a list of tasks that have that tag.
  final Map<String, List<String>> filters = {
    'Actions': ['All', 'Home', 'Errands', 'Study'],
    'Flows': ['All', 'Morning', 'Evening', 'Wellness'],
    'Moments': ['All', 'Events', 'Deadlines', 'Appointments'],
    'Thoughts': ['All', 'Ideas', 'Journal'],
  };

  /// A list of all the hidden tags in the app.
  /// It is a map of tag names to a set of hidden tags.
  /// This is used to filter out tags that are not relevant to the user.
  final Map<String, Set<String>> hiddenFilters = {
    'Actions': {},
    'Flows': {},
    'Moments': {},
    'Thoughts': {},
  };
}
