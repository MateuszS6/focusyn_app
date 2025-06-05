// Core Flutter imports for UI components and state management
import 'package:flutter/material.dart';

// Application-specific imports
import 'package:focusyn_app/constants/theme_icons.dart'; // Custom icon definitions
import 'package:focusyn_app/services/task_service.dart'; // Task management service
import 'package:focusyn_app/services/brain_service.dart'; // Brain points management
import 'package:focusyn_app/services/flow_service.dart'; // Flow session history
import 'package:focusyn_app/constants/keys.dart'; // Application constants and keys
import 'package:focusyn_app/constants/quotes.dart'; // Daily motivational quotes
import 'package:focusyn_app/pages/account_page.dart'; // User account page
import 'package:focusyn_app/pages/task_page.dart'; // Task management page
import 'package:fl_chart/fl_chart.dart'; // Chart visualization library
import 'package:firebase_auth/firebase_auth.dart'; // Firebase authentication
import 'dart:math' as math; // Math utilities
import 'package:focusyn_app/pages/onboarding_page.dart'; // User onboarding page
import 'package:focusyn_app/services/cloud_service.dart'; // Cloud synchronization
import 'package:focusyn_app/utils/my_scroll_shadow.dart'; // Custom scroll shadow widget
import 'package:hive/hive.dart'; // Local storage

/// A page that displays the user's daily tasks, focus sessions, and progress.
///
/// This page serves as the main dashboard for users to:
/// - View and manage their daily tasks
/// - Track focus sessions and flow states
/// - Monitor their progress through various metrics
/// - Access quick actions for task management
/// - View their weekly progress in a visual chart
///
/// The page is divided into several sections:
/// 1. Header with date and brain points
/// 2. Focus session controls and timer
/// 3. Task list with completion tracking
/// 4. Weekly progress chart
/// 5. Quick action buttons for task management
///
/// The page maintains its own state for:
/// - Focus session timer
/// - Task completion status
/// - Brain points balance
/// - Weekly progress data
///
/// It also handles various user interactions:
/// - Starting/stopping focus sessions
/// - Completing tasks
/// - Adding new tasks
/// - Managing brain points
/// - Viewing detailed progress
class TodayPage extends StatefulWidget {
  const TodayPage({super.key});

  @override
  State<TodayPage> createState() => _TodayPageState();
}

/// The state class for [TodayPage].
///
/// This class manages:
/// - Timer state for focus sessions
/// - Task completion status
/// - UI updates and animations
/// - User interactions and input validation
///
/// It provides methods for:
/// - Starting and stopping focus sessions
/// - Managing task completion
/// - Updating brain points
/// - Building the UI components
///
/// The state is updated in response to:
/// - Timer ticks
/// - User interactions
/// - Task completion events
/// - Focus session state changes
class _TodayPageState extends State<TodayPage> {
  DateTime? _lastUpdateDate;
  List<DateTime>? _cachedCompletions;
  late int _points;
  List<dynamic> _actions = [];

  @override
  void initState() {
    super.initState();
    // Initialize points from Hive cache
    _points = Hive.box(Keys.brainBox).get(Keys.brainPoints, defaultValue: 100);
    _refreshFlowHistory();
    // Schedule the initial data load for after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    try {
      // First sync with Firestore
      await CloudService.syncOnLogin(
        Hive.box<List>(Keys.taskBox),
        Hive.box(Keys.filterBox),
        Hive.box(Keys.brainBox),
        Hive.box(Keys.historyBox),
      );

      // Then update local state
      if (!mounted) return;
      setState(() {
        _points = BrainService.getPoints();
        _actions = TaskService.tasks[Keys.actions] ?? [];
      });

      _refreshFlowHistory();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to sync: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Refreshes the flow history cache and updates the last update date.
  ///
  /// This method retrieves the flow completions for the last 7 days and updates:
  /// - The cached completions list
  /// - The last update date
  ///
  /// It also ensures the UI is updated when the data is refreshed.
  void _refreshFlowHistory() {
    _cachedCompletions = _getFlowCompletions();
    _lastUpdateDate = DateTime.now();
    if (mounted) {
      setState(() {});
    }
  }

  /// Refreshes the data cache and updates the last update date.
  ///
  /// This method checks if the cached data is outdated and refreshes it if necessary.
  /// It compares the last update date with the current date to determine if an update is needed.
  ///
  /// The method also ensures the UI is updated when the data is refreshed.
  void _refreshData() {
    final now = DateTime.now();
    // Refresh if there's no cached data or if it's a new day
    if (_lastUpdateDate == null || !_isSameDate(_lastUpdateDate!, now)) {
      _refreshFlowHistory();
    }
  }

  /// Builds the main page layout.
  ///
  /// This method constructs the entire Today page UI, which includes:
  /// 1. Header section with date and user info
  /// 2. Greeting card with brain points
  /// 3. Daily quote card
  /// 4. Task summary card
  /// 5. Flow streak card
  /// 6. Weekly progress chart
  ///
  /// The layout is built using a ListView with padding and includes:
  /// - SafeArea for proper display on different devices
  /// - RefreshIndicator for pull-to-refresh functionality
  /// - MyScrollShadow for visual feedback during scrolling
  ///
  /// The method also:
  /// - Checks for data refresh needs
  /// - Formats the current date
  /// - Handles user authentication state
  @override
  Widget build(BuildContext context) {
    _refreshData(); // Check if we need to refresh data
    final today = DateTime.now();
    final monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      body: MyScrollShadow(
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _loadData,
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                // Header with date and user info
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${monthNames[today.month - 1]} ${today.day}",
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Today",
                          style: Theme.of(context).textTheme.displayLarge,
                        ),
                      ],
                    ),
                    // User avatar and onboarding button
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(ThemeIcons.onboarding),
                            tooltip: 'Replay Onboarding',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const OnboardingPage(),
                                ),
                              );
                            },
                            padding: const EdgeInsets.all(8),
                            constraints: const BoxConstraints(),
                            iconSize: 24,
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AccountPage(),
                                ),
                              );
                              // Reload data when returning from account page
                              _loadData();
                            },
                            child: CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.orange.shade100,
                              child: Text(
                                currentUser?.displayName
                                        ?.substring(0, 1)
                                        .toUpperCase() ??
                                    'M',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange.shade700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _greetingCard(_points),
                const SizedBox(height: 24),
                _quoteCard(),
                const SizedBox(height: 24),
                _summaryCard(_actions.length),
                const SizedBox(height: 24),
                _flowStreakCard(),
                const SizedBox(height: 24),
                _weeklyProgressChart(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  int _calculateStreak(List<DateTime> dates) {
    if (dates.isEmpty) return 0;

    final today = DateTime.now();
    final sorted = dates.toSet().toList()..sort((a, b) => b.compareTo(a));

    // If the last completion was not today, streak is broken
    if (!_isSameDate(sorted.first, today)) return 0;

    int streak = 1;
    DateTime currentDate = today;

    for (int i = 1; i < sorted.length; i++) {
      currentDate = currentDate.subtract(const Duration(days: 1));
      if (_isSameDate(sorted[i], currentDate)) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }

  List<DateTime> _getFlowCompletions() {
    // Get all completions from the history service
    final allCompletions = FlowService.getCompletions();

    // Filter to only include completions from the last 7 days
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));

    return allCompletions
        .where(
          (date) =>
              date.isAfter(sevenDaysAgo) || _isSameDate(date, sevenDaysAgo),
        )
        .toList();
  }

  bool _isSameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// Builds the greeting card with brain points display.
  ///
  /// This method creates a card that shows:
  /// 1. Time-based greeting (morning/afternoon/evening)
  /// 2. User's name
  /// 3. Brain points status with:
  ///    - Current points display
  ///    - Progress bar
  ///    - Add points button
  /// 4. Status message based on points level:
  ///    - ≥70 points: "You're doing great today!"
  ///    - ≥40 points: "Keep up the good work!"
  ///    - <40 points: "Time to recharge"
  ///
  /// The card uses:
  /// - Gradient background
  /// - Custom shadows
  /// - Responsive layout
  /// - Interactive elements
  Widget _greetingCard(int points) {
    // Determine greeting based on time of day
    final hour = DateTime.now().hour;
    String greeting =
        hour < 12
            ? "Good morning"
            : hour < 17
            ? "Good afternoon"
            : "Good evening";

    final currentUser = FirebaseAuth.instance.currentUser;

    // Set status message and color based on points level
    final statusMessage =
        points >= 70
            ? "You're doing great today!"
            : points >= 40
            ? "Keep up the good work!"
            : "Time to recharge";

    final statusColor =
        points >= 70
            ? Colors.green[700]!
            : points >= 40
            ? Colors.orange[700]!
            : Colors.red[700]!;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.green.shade50, Colors.white],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$greeting, ${currentUser?.displayName ?? 'there'} 👋",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            statusMessage,
            style: TextStyle(
              fontSize: 14,
              color: statusColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        "Brain Points",
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder:
                                (context) => AlertDialog(
                                  title: const Text("About Brain Points"),
                                  content: const Text(
                                    "Brain Points are an approximate measure of your mental energy. "
                                    "Since they can't be measured precisely, you can manually adjust them "
                                    "to better reflect your current state. This helps maintain a more "
                                    "accurate representation of your mental capacity throughout the day.",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text("Got it"),
                                    ),
                                  ],
                                ),
                          );
                        },
                        child: Icon(
                          ThemeIcons.info,
                          size: 16,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "$points / 100",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _showAddBrainPointsDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[100],
                  foregroundColor: Colors.blue[700],
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(ThemeIcons.add, size: 16, color: Colors.blue[700]),
                    const SizedBox(width: 4),
                    Text(
                      "Add",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: points / 100,
              minHeight: 6,
              backgroundColor: Colors.blue[100],
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the daily quote card.
  ///
  /// This method creates a card that displays:
  /// 1. A random motivational quote from the quotes collection
  /// 2. The quote's category (e.g., Motivation, Productivity)
  /// 3. The quote's author
  ///
  /// The card features:
  /// - Gradient background with purple theme
  /// - Custom shadow for depth
  /// - Proper text formatting and spacing
  /// - Responsive layout
  Widget _quoteCard() {
    final quote = Quotes.getRandomQuote();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Daily Quote", style: Theme.of(context).textTheme.displayMedium),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.purple.shade50, Colors.white],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(13),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    quote.category,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.purple[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '"${quote.text}"',
                style: const TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  "― ${quote.author}",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds the task summary card.
  ///
  /// This method creates a card that shows:
  /// 1. Task counts by category:
  ///    - Actions (immediate tasks)
  ///    - Flows (scheduled focus sessions)
  ///    - Moments (special events)
  /// 2. Total brain points for today's tasks
  /// 3. Next upcoming tasks with:
  ///    - Task title
  ///    - Scheduled time
  ///    - Category icon
  ///
  /// The card features:
  /// - Interactive task type indicators
  /// - Navigation to detailed task pages
  /// - Visual representation of task counts
  /// - Upcoming task preview
  Widget _summaryCard(int actionsCount) {
    final today = DateTime.now();
    final formattedDate =
        "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

    // Get tasks from different categories
    final actions = TaskService.tasks[Keys.actions] ?? [];
    final flows = TaskService.tasks[Keys.flows] ?? [];
    final moments = TaskService.tasks[Keys.moments] ?? [];

    // Filter today's tasks
    final todayFlows =
        flows.where((task) => task.date == formattedDate).toList();
    final todayMoments =
        moments.where((task) => task.date == formattedDate).toList();

    // Calculate total brain points from uncompleted tasks
    final totalActionBrainPoints = actions.fold<int>(
      0,
      (sum, action) => sum + action.brainPoints!.toInt(),
    );
    final totalFlowBrainPoints = flows.fold<int>(0, (sum, flow) {
      final flowDate = DateTime.tryParse(flow.date ?? '');
      if (flowDate == null) return sum;
      // Only count flows that are due today or before today
      if (flowDate.isBefore(today) || _isSameDate(flowDate, today)) {
        return sum + flow.brainPoints!.toInt();
      }
      return sum;
    });
    final totalBrainPoints = totalActionBrainPoints + totalFlowBrainPoints;

    // Get next upcoming tasks
    final nextFlow = todayFlows.isNotEmpty ? todayFlows.first : null;
    final nextMoment = todayMoments.isNotEmpty ? todayMoments.first : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Today's Tasks",
              style: Theme.of(context).textTheme.displayMedium,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Text(
                    "$totalBrainPoints",
                    style: TextStyle(
                      color: Colors.orange[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text("BP", style: TextStyle(color: Colors.orange[700])),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.orange.shade50, Colors.white],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(13),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildTaskType(
                    icon: ThemeIcons.actionsAlt,
                    count: actionsCount,
                    label: "Actions",
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TaskPage(category: Keys.actions),
                          ),
                        ),
                  ),
                  _buildTaskType(
                    icon: ThemeIcons.flowsAlt,
                    count: todayFlows.length,
                    label: "Flows",
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TaskPage(category: Keys.flows),
                          ),
                        ),
                  ),
                  _buildTaskType(
                    icon: ThemeIcons.moments,
                    count: todayMoments.length,
                    label: "Moments",
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TaskPage(category: Keys.moments),
                          ),
                        ),
                  ),
                ],
              ),
              if (nextFlow != null || nextMoment != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Next Up",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (nextFlow != null)
                        _buildNextTask(
                          icon: ThemeIcons.flows,
                          title: nextFlow.title,
                          time: nextFlow.time ?? '',
                        ),
                      if (nextMoment != null)
                        _buildNextTask(
                          icon: ThemeIcons.moments,
                          title: nextMoment.title,
                          time: nextMoment.time ?? '',
                        ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  /// Builds a task type indicator with icon and count.
  ///
  /// This method creates a visual representation of a task category that shows:
  /// 1. Category icon
  /// 2. Task count badge (if count > 0)
  /// 3. Category label
  ///
  /// The indicator features:
  /// - Interactive tap handling
  /// - Visual feedback for empty/active states
  /// - Consistent styling with the app theme
  Widget _buildTaskType({
    required IconData icon,
    required int count,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Stack(
            children: [
              Icon(icon, size: 32, color: Colors.orange[700]),
              if (count > 0) ...[
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.orange[700],
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      count.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.orange[700],
              fontWeight: count > 0 ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a next task item with icon, title, and time.
  ///
  /// This method creates a compact task preview that shows:
  /// 1. Task category icon
  /// 2. Task title (with ellipsis for overflow)
  /// 3. Scheduled time
  ///
  /// The item features:
  /// - Consistent styling with the app theme
  /// - Proper text overflow handling
  /// - Clear visual hierarchy
  Widget _buildNextTask({
    required IconData icon,
    required String title,
    required String time,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.orange[700]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(time, style: TextStyle(fontSize: 12, color: Colors.orange[700])),
        ],
      ),
    );
  }

  /// Builds the flow streak card.
  ///
  /// This method creates a card that displays:
  /// 1. Current flow streak count
  /// 2. Streak status message
  /// 3. Visual indicator (fire emoji)
  ///
  /// The streak is calculated based on consecutive days with flow completions:
  /// - A streak is maintained by completing at least one flow per day
  /// - The streak breaks if a day is missed
  /// - The current day must have a completion to maintain the streak
  ///
  /// The card features:
  /// - Gradient background with teal theme
  /// - Custom shadow for depth
  /// - Dynamic streak count display
  /// - Motivational message based on streak status
  Widget _flowStreakCard() {
    final streak = _calculateStreak(_cachedCompletions ?? []);
    final streakText =
        streak == 0
            ? "Complete a flow today to start your streak!"
            : "You've completed flows $streak day${streak == 1 ? '' : 's'} in a row.";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Flow Streak", style: Theme.of(context).textTheme.displayMedium),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.teal.shade50, Colors.white],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(13),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text("🔥", style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 8),
                  if (streak > 0) ...[
                    Text(
                      streak.toString(),
                      style: TextStyle(
                        color: Colors.teal[700],
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              Text(
                streakText,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds the weekly progress chart.
  ///
  /// This method creates a bar chart that visualizes:
  /// 1. Daily flow completions for the last 7 days
  /// 2. Relative progress compared to the best day
  /// 3. Current day highlight
  ///
  /// The chart features:
  /// - Interactive bar display
  /// - Day labels (Mn, Te, Wd, etc.)
  /// - Completion count above each bar
  /// - Gradient fill for visual appeal
  /// - Maximum completions indicator
  ///
  /// Data processing includes:
  /// - Filtering completions for the last 7 days
  /// - Calculating relative percentages
  /// - Determining maximum completions
  /// - Formatting day labels
  Widget _weeklyProgressChart() {
    final completions = _cachedCompletions ?? [];
    final today = DateTime.now();

    // Generate list of last 7 days
    final last7Days = List.generate(
      7,
      (i) => today.subtract(Duration(days: 6 - i)),
    );

    // Calculate completions per day
    final completedPerDay =
        last7Days.map((day) {
          final dayCompletions =
              completions.where((d) => _isSameDate(d, day)).length;
          return {'count': dayCompletions, 'date': day};
        }).toList();

    // Find maximum completions for scaling
    final maxCompletions = completedPerDay.fold<int>(
      0,
      (max, day) => math.max(max, day['count'] as int),
    );

    // Calculate percentages for bar heights
    for (var day in completedPerDay) {
      day['percentage'] =
          maxCompletions > 0 ? (day['count'] as int) / maxCompletions : 0.0;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Weekly Progress",
              style: Theme.of(context).textTheme.displayMedium,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "Max: ${maxCompletions > 0 ? maxCompletions : 'No'} flows/day",
                style: TextStyle(
                  color: Colors.green[700],
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.green.shade50, Colors.white],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(13),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 200,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: 1.0,
                    minY: 0,
                    groupsSpace: 35, // Increased space between bars
                    barTouchData: BarTouchData(
                      enabled: false,
                    ), // Disable touch interaction since values are shown above bars
                    titlesData: FlTitlesData(
                      show: true,
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 32,
                          getTitlesWidget: (value, meta) {
                            final data = completedPerDay[value.toInt()];
                            final count = data['count'] as int;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                count.toString(),
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          getTitlesWidget: (value, meta) {
                            final date =
                                completedPerDay[value.toInt()]['date']
                                    as DateTime;
                            final dayLabel =
                                [
                                  'Mn',
                                  'Te',
                                  'Wd',
                                  'Tu',
                                  'Fr',
                                  'St',
                                  'Sn',
                                ][date.weekday % 7];
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                dayLabel,
                                style: TextStyle(
                                  color:
                                      _isSameDate(date, today)
                                          ? Colors.green[700]
                                          : Colors.black54,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    gridData: FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    barGroups: List.generate(7, (index) {
                      final data = completedPerDay[index];
                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: data['percentage'] as double,
                            width: 8,
                            gradient: LinearGradient(
                              colors: [
                                Colors.green.withAlpha(179),
                                Colors.green,
                              ],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(3),
                              topRight: Radius.circular(3),
                            ),
                            backDrawRodData: BackgroundBarChartRodData(
                              show: true,
                              toY: 1,
                              color: Colors.white.withAlpha(13),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Shows daily flow completions relative to your best day",
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Shows a dialog for adding brain points.
  ///
  /// This method creates a dialog that allows users to:
  /// 1. Enter a number of brain points to add
  /// 2. Validate the input (must be between 1 and 100)
  /// 3. Confirm or cancel the action
  ///
  /// The dialog features:
  /// - Input field with number keyboard
  /// - Clear validation feedback
  /// - Success/error messages
  /// - Proper state management
  ///
  /// After successful addition:
  /// - Updates the brain points
  /// - Shows a success message
  /// - Refreshes the UI
  void _showAddBrainPointsDialog() {
    final controller = TextEditingController(text: "5");
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Add Brain Points"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "How many brain points would you like to add?",
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Points to add",
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Icon(ThemeIcons.cancel, size: 24),
              ),
              ElevatedButton(
                onPressed: () {
                  final points = int.tryParse(controller.text) ?? 0;
                  if (points > 0 && points <= 100) {
                    BrainService.addPoints(points);
                    Navigator.pop(context);
                    if (mounted) {
                      setState(() {});
                      scaffoldMessenger.showSnackBar(
                        SnackBar(
                          content: Text("Added $points brain points!"),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  } else {
                    scaffoldMessenger.showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Please enter a number between 1 and 100",
                        ),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
                child: const Icon(ThemeIcons.done, size: 24),
              ),
            ],
          ),
    );
  }
}
