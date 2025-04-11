import 'package:flutter/material.dart';
import 'package:focusyn_app/data/app_data.dart';
import 'package:focusyn_app/data/brain_points_service.dart';
import 'package:focusyn_app/data/keys.dart';
import 'package:focusyn_app/pages/account_page.dart';
import 'package:focusyn_app/pages/focus_task_page.dart';
import 'package:focusyn_app/util/my_app_bar.dart';
import 'package:focusyn_app/util/tap_effect_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final points = BrainPointsService.getPoints();
    final actions = AppData.instance.tasks[Keys.actions] ?? [];

    return Scaffold(
      appBar: MyAppBar(
        title: Keys.home,
        actions: [
          IconButton(icon: Icon(Icons.notifications_rounded), onPressed: () {}),
          IconButton(
            icon: Icon(Icons.account_circle_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AccountPage()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 16, top: 16, right: 16),
        child: RefreshIndicator(
          onRefresh: () async => setState(() {}),
          child: ListView(
            children: [
              _greetingCard(points),
              const SizedBox(height: 16),
              _quoteCard(),
              const SizedBox(height: 16),
              _summaryCard(actions.length),
              const SizedBox(height: 16),
              _flowStreakCard(),
              const SizedBox(height: 16),
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
    final greeting =
        hour < 12
            ? "Good morning"
            : hour < 17
            ? "Good afternoon"
            : "Good evening";

    String statusMessage;
    Color statusColor;
    if (points >= 80) {
      statusMessage = "You're at peak mental energy!";
      statusColor = Colors.green;
    } else if (points >= 50) {
      statusMessage = "You're doing great!";
      statusColor = Colors.blue;
    } else if (points >= 20) {
      statusMessage = "Time for a quick break?";
      statusColor = Colors.orange;
    } else {
      statusMessage = "Consider taking a rest";
      statusColor = Colors.red;
    }

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "$greeting, Mateusz 👋",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              statusMessage,
              style: TextStyle(
                fontSize: 16,
                color: statusColor,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "$points / 100 brain points",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                ),
                TextButton.icon(
                  onPressed: _showAddBrainPointsDialog,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text(
                    "Add",
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: points / 100,
                minHeight: 10,
                color: statusColor,
                backgroundColor: Colors.grey[300],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quoteCard() {
    final quote = _randomQuote();
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.purple[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              '"${quote["text"]}"',
              style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                "― ${quote["author"]}",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, String> _randomQuote() {
    final quotes = [
      {
        "text":
            "Discipline is choosing between what you want now and what you want most.",
        "author": "Abraham Lincoln",
      },
      {"text": "Small progress is still progress.", "author": "Unknown"},
      {
        "text": "Do one thing at a time, and do it well.",
        "author": "Steve Jobs",
      },
    ];
    quotes.shuffle();
    return quotes.first;
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

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.orange[50] ?? Colors.orange,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Today's Tasks",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  "$totalBrainPoints BP",
                  style: TextStyle(
                    color: Colors.orange[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTaskType(
                  icon: Icons.whatshot_rounded,
                  count: actionsCount,
                  label: "Actions",
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FocusTaskPage(category: Keys.actions),
                        ),
                      ),
                ),
                _buildTaskType(
                  icon: Icons.event_repeat,
                  count: todayFlows.length,
                  label: "Flows",
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FocusTaskPage(category: Keys.flows),
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
                          builder: (_) => FocusTaskPage(category: Keys.moments),
                        ),
                      ),
                ),
              ],
            ),
            if (nextFlow != null || nextMoment != null) ...[
              const SizedBox(height: 16),
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
                  icon: Icons.event_repeat,
                  title: nextFlow[Keys.title],
                  time: nextFlow[Keys.time],
                ),
              if (nextMoment != null)
                _buildNextTask(
                  icon: Icons.event_rounded,
                  title: nextMoment[Keys.title],
                  time: nextMoment[Keys.time],
                ),
            ],
          ],
        ),
      ),
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
    final streak = _calculateStreak(_getFlowCompletions());
    final streakText =
        streak == 0
            ? "Complete a flow today to start your streak!"
            : "You've completed flows $streak day${streak == 1 ? '' : 's'} in a row.";

    return TapEffectCard(
      backgroundColor: Colors.teal[50]!,
      borderRadius: 16,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                "🔥 Flow Streak",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              if (streak > 0) ...[
                const SizedBox(width: 8),
                Text(
                  streak.toString(),
                  style: TextStyle(
                    color: Colors.teal[700],
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(streakText),
        ],
      ),
    );
  }

  Widget _weeklyProgressChart() {
    final completions = _getFlowCompletions();
    final today = DateTime.now();
    final flows = AppData.instance.tasks[Keys.flows] ?? [];
    final totalFlows = flows.length;
    const maxBarHeight = 100.0;

    final last7Days = List.generate(
      7,
      (i) => today.subtract(Duration(days: 6 - i)),
    );

    final completedPerDay =
        last7Days.map((day) {
          final dayCompletions =
              completions.where((d) => _isSameDate(d, day)).length;
          return {
            'count': dayCompletions,
            'percentage': totalFlows > 0 ? dayCompletions / totalFlows : 0.0,
          };
        }).toList();

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.green[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Weekly Flow Completion",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  "Total: $totalFlows flows",
                  style: TextStyle(color: Colors.green[700], fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(7, (i) {
                  final dayLabel =
                      ['S', 'M', 'T', 'W', 'T', 'F', 'S'][last7Days[i].weekday %
                          7];
                  final dayData = completedPerDay[i];
                  final height = (dayData['percentage']! * maxBarHeight).clamp(
                    0.0,
                    maxBarHeight,
                  );

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 20,
                        height: height,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(
                          child: Text(
                            dayData['count'].toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dayLabel,
                        style: TextStyle(
                          color:
                              _isSameDate(last7Days[i], today)
                                  ? Colors.green[700]
                                  : Colors.black54,
                          fontWeight:
                              _isSameDate(last7Days[i], today)
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Shows percentage of total flows completed each day",
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
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
