import 'package:flutter/material.dart';
import 'package:focusyn_app/data/app_data.dart';
import 'package:focusyn_app/data/brain_points_service.dart';
import 'package:focusyn_app/data/keys.dart';
import 'package:focusyn_app/data/quotes.dart';
import 'package:focusyn_app/pages/account_page.dart';
import 'package:focusyn_app/pages/task_page.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math' as math;

class TodayPage extends StatefulWidget {
  const TodayPage({super.key});

  @override
  State<TodayPage> createState() => _TodayPageState();
}

class _TodayPageState extends State<TodayPage> {
  DateTime? _lastUpdateDate;
  List<DateTime>? _cachedCompletions;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    final now = DateTime.now();
    // Refresh if there's no cached data or if it's a new day
    if (_lastUpdateDate == null || !_isSameDate(_lastUpdateDate!, now)) {
      _cachedCompletions = _getFlowCompletions();
      _lastUpdateDate = now;
    }
  }

  @override
  Widget build(BuildContext context) {
    _refreshData(); // Check if we need to refresh data
    final points = BrainPointsService.getPoints();
    final actions = AppData.instance.tasks[Keys.actions] ?? [];
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

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            _cachedCompletions = null; // Force refresh of completions
            _lastUpdateDate = null;
            setState(() {});
          },
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
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
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.notifications_rounded),
                          onPressed: () {},
                          padding: const EdgeInsets.all(8),
                          constraints: const BoxConstraints(),
                          iconSize: 24,
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AccountPage(),
                              ),
                            );
                          },
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.orange.shade100,
                            child: Text(
                              FirebaseAuth.instance.currentUser?.displayName
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
              _greetingCard(points),
              const SizedBox(height: 24),
              _quoteCard(),
              const SizedBox(height: 24),
              _summaryCard(actions.length),
              const SizedBox(height: 24),
              _flowStreakCard(),
              const SizedBox(height: 24),
              _weeklyProgressChart(),
            ],
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
    final flows = AppData.instance.tasks[Keys.flows] ?? [];
    final completions = <DateTime>[];

    for (final task in flows) {
      final history = task[Keys.history];
      if (history is List) {
        for (final date in history) {
          if (date is String) {
            final parsed = DateTime.tryParse(date);
            if (parsed != null) {
              // Only add dates from the last 7 days
              final now = DateTime.now();
              final sevenDaysAgo = now.subtract(const Duration(days: 7));
              if (parsed.isAfter(sevenDaysAgo) ||
                  _isSameDate(parsed, sevenDaysAgo)) {
                completions.add(parsed);
              }
            }
          }
        }
      }
    }

    return completions;
  }

  bool _isSameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Widget _greetingCard(int points) {
    final hour = DateTime.now().hour;
    String greeting =
        hour < 12
            ? "Good morning"
            : hour < 17
            ? "Good afternoon"
            : "Good evening";

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
            "$greeting, ${FirebaseAuth.instance.currentUser?.displayName ?? 'there'} 👋",
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
                          Icons.info_outline,
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
                    Icon(Icons.add, size: 16, color: Colors.blue[700]),
                    const SizedBox(width: 4),
                    Text(
                      "Add Points",
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

  Widget _summaryCard(int actionsCount) {
    final today = DateTime.now();
    final formattedDate =
        "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

    final flows = AppData.instance.tasks[Keys.flows] ?? [];
    final moments = AppData.instance.tasks[Keys.moments] ?? [];

    final todayFlows =
        flows.where((flow) => flow[Keys.date] == formattedDate).toList();
    final todayMoments =
        moments.where((moment) => moment[Keys.date] == formattedDate).toList();

    final totalBrainPoints =
        todayFlows.fold<int>(
          0,
          (sum, flow) => sum + ((flow[Keys.brainPoints] as int?) ?? 0),
        ) +
        todayMoments.fold<int>(
          0,
          (sum, moment) => sum + ((moment[Keys.brainPoints] as int?) ?? 0),
        );

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
              child: Text(
                "$totalBrainPoints BP",
                style: TextStyle(
                  color: Colors.orange[700],
                  fontWeight: FontWeight.bold,
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
                    icon: Icons.check_rounded,
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
                    icon: Icons.replay_rounded,
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
                    icon: Icons.event_rounded,
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
                          icon: Icons.replay_circle_filled_rounded,
                          title: nextFlow[Keys.title],
                          time: nextFlow[Keys.time],
                        ),
                      if (nextMoment != null)
                        _buildNextTask(
                          icon: Icons.calendar_today_rounded,
                          title: nextMoment[Keys.title],
                          time: nextMoment[Keys.time],
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

  Widget _weeklyProgressChart() {
    final completions = _cachedCompletions ?? [];
    final today = DateTime.now();

    // Get the maximum completions in a day to use as the baseline for percentage
    final last7Days = List.generate(
      7,
      (i) => today.subtract(Duration(days: 6 - i)),
    );
    final completedPerDay =
        last7Days.map((day) {
          final dayCompletions =
              completions.where((d) => _isSameDate(d, day)).length;
          return {'count': dayCompletions, 'date': day};
        }).toList();

    // Find the maximum completions in a day
    final maxCompletions = completedPerDay.fold<int>(
      0,
      (max, day) => math.max(max, day['count'] as int),
    );

    // Update the data to include percentages based on the maximum
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
                    ), // Disabled tooltips since we show values on top
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
                            width: 8, // Keep the thinner bars
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

  void _showAddBrainPointsDialog() {
    final controller = TextEditingController(text: "5");
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
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () {
                  final points = int.tryParse(controller.text) ?? 0;
                  if (points > 0 && points <= 100) {
                    BrainPointsService.addPoints(points);
                    Navigator.pop(context);
                    setState(() {});
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Added $points brain points!"),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Please enter a number between 1 and 100",
                        ),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
                child: const Text("Add"),
              ),
            ],
          ),
    );
  }
}
