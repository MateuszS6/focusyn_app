/// A collection of string constants used as keys throughout the application.
/// This class provides a centralized location for all string keys used in:
/// - App identification
/// - Local storage (Hive boxes)
/// - UI elements
/// - Data models
/// - Settings
abstract class Keys {
  // App Identification
  // Basic information about the application
  static const String appName = 'Focusyn';
  static const String aiName = 'Synthe';

  // Local Storage Keys
  // Names of Hive boxes used for persistent storage
  static const String brainBox = 'brainBox';
  static const String taskBox = 'taskBox';
  static const String historyBox = 'historyBox';
  static const String filterBox = 'filterBox';
  static const String settingBox = 'settingBox';
  static const String chatBox = 'chatBox';

  // Page Titles
  // Names of main app sections and pages
  static const String today = 'Today';
  static const String account = 'Account';
  static const String settings = 'Settings';
  static const String privacy = 'Privacy';
  static const String focuses = 'Focuses';
  static const String planner = 'Planner';

  // Focus Types
  // Categories of focus available in the app
  static const String actions = 'Actions';
  static const String flows = 'Flows';
  static const String moments = 'Moments';
  static const String thoughts = 'Thoughts';

  // Task Model Fields
  // Keys used in task data structure
  static const String id = 'id';
  static const String title = 'title';
  static const String priority = 'priority';
  static const String brainPoints = 'brainPoints';
  static const String date = 'date';
  static const String time = 'time';
  static const String duration = 'duration';
  static const String repeat = 'repeat';
  static const String location = 'location';
  static const String createdAt = 'createdAt';

  // List and Filter Keys
  // Keys used for task filtering and categorization
  static const String list = 'list';
  static const String all = 'All';

  // Settings Keys
  // Keys for user preferences and app configuration
  static const String onboardingDone = 'onboardingDone';
  static const String navBarTextBehaviour = 'navBarTextBehaviour';
  static const String notisEnabled = 'notisEnabled';
  static const String notiHour = 'notiHour';
  static const String notiMinute = 'notiMinute';
}
