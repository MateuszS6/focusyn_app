import 'package:flutter/material.dart';

/// A centralized collection of Material Icons used throughout the application.
/// This class provides a single source of truth for all icon constants,
/// making it easier to maintain consistency and update icons across the app.
class ThemeIcons {
  // Main Navigation Icons
  // Icons used in the bottom navigation bar and main app sections
  static const IconData today = Icons.today_rounded;
  static const IconData focuses = Icons.auto_awesome_motion_rounded;
  static const IconData ai = Icons.auto_awesome_rounded;
  static const IconData planner = Icons.calendar_month_rounded;

  // Secondary Navigation Icons
  // Icons for additional app sections and features
  static const IconData notifications = Icons.notifications_rounded;
  static const IconData onboarding = Icons.school_rounded;
  static const IconData settings = Icons.settings_rounded;

  // Focus Category Icons
  // Icons representing different types of focuses and their alternatives
  static const IconData actions = Icons.check_circle_rounded;
  static const IconData actionsAlt = Icons.check_rounded;
  static const IconData flows = Icons.replay_circle_filled_rounded;
  static const IconData flowsAlt = Icons.replay_rounded;
  static const IconData moments = Icons.event_rounded;
  static const IconData thoughts = Icons.lightbulb_rounded;
  static const IconData tasks = Icons.task_alt_rounded;

  // Navigation and Action Icons
  // Common UI interaction icons
  static const IconData back = Icons.arrow_back_ios_rounded;
  static const IconData done = Icons.done_rounded;
  static const IconData sort = Icons.sort_rounded;
  static const IconData add = Icons.add_rounded;
  static const IconData delete = Icons.delete_forever_rounded;
  static const IconData open = Icons.chevron_right_rounded;
  static const IconData next = Icons.arrow_forward_rounded;
  static const IconData cancel = Icons.close_rounded;
  static const IconData send = Icons.send_rounded;
  static const IconData clear = Icons.clear_all_rounded;

  // General Purpose Icons
  // Common symbols used across different features
  static const IconData play = Icons.play_arrow_rounded;
  static const IconData info = Icons.info_rounded;
  static const IconData help = Icons.help_rounded;
  static const IconData robot = Icons.smart_toy_rounded;
  static const IconData streak = Icons.local_fire_department_rounded;
  static const IconData noEvents = Icons.event_available_rounded;

  // Task Management Icons
  // Icons specific to task creation and management
  static const IconData text = Icons.title_rounded;
  static const IconData priority = Icons.priority_high_rounded;
  static const IconData brainPoints = Icons.psychology_rounded;
  static const IconData date = Icons.today_rounded;
  static const IconData time = Icons.access_time_filled_rounded;
  static const IconData duration = Icons.timer_rounded;
  static const IconData repeat = Icons.repeat_rounded;
  static const IconData location = Icons.location_on_rounded;
  static const IconData tag = Icons.label_rounded;

  // User Account Icons
  // Icons related to user profile and authentication
  static const IconData user = Icons.person_rounded;
  static const IconData email = Icons.email_rounded;
  static const IconData lock = Icons.lock_rounded;
  static const IconData visibilityOn = Icons.visibility_rounded;
  static const IconData visibilityOff = Icons.visibility_off_rounded;

  // Settings and Data Icons
  // Icons for app settings, data management, and legal information
  static const IconData data = Icons.data_usage_rounded;
  static const IconData security = Icons.shield_rounded;
  static const IconData privacy = Icons.privacy_tip_rounded;
  static const IconData terms = Icons.description_rounded;
  static const IconData logout = Icons.logout_rounded;
}
