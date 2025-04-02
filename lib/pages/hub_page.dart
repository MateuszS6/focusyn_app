import 'package:flutter/material.dart';
import 'package:focusyn_app/data/app_data.dart';
import 'package:focusyn_app/data/brain_points_service.dart';
import 'package:focusyn_app/data/keys.dart';
import 'package:focusyn_app/pages/account_page.dart';
import 'package:focusyn_app/util/my_app_bar.dart';
import 'package:focusyn_app/util/tap_effect_card.dart';

class HubPage extends StatefulWidget {
  const HubPage({super.key});

  @override
  State<HubPage> createState() => _HubPageState();
}

class _HubPageState extends State<HubPage> {
  @override
  Widget build(BuildContext context) {
    final points = BrainPointsService.getPoints();
    final actions = AppData.instance.tasks[Keys.actions] ?? [];

    final streak = _calculateStreak(_getFlowCompletions());

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

              TapEffectCard(
                backgroundColor: Colors.teal[50]!,
                borderRadius: 16,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "🔥 Flow Streak",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "You've completed flows $streak day${streak == 1 ? '' : 's'} in a row.",
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              _weeklyProgressChart(),
            ],
          ),
        ),
      ),
    );
  }

  int _calculateStreak(List<DateTime> dates) {
    final today = DateTime.now();
    final sorted = dates.toSet().toList()..sort((a, b) => b.compareTo(a));

    int streak = 0;
    for (int i = 0; i < sorted.length; i++) {
      final expected = today.subtract(Duration(days: i));
      if (sorted.any((d) => _isSameDate(d, expected))) {
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
          final parsed = DateTime.tryParse(date);
          if (parsed != null) completions.add(parsed);
        }
      }
    }

    return completions;
  }

  Widget _greetingCard(int points) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Good day, Mateusz 👋",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "You have $points / 100 brain points left",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: points / 100,
              color: Colors.blue,
              backgroundColor: Colors.grey[300],
            ),
          ],
        ),
      ),
    );
  }

  bool _isSameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

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
    return TapEffectCard(
      onTap: () {},
      borderRadius: 16,
      backgroundColor: Colors.orange[50] ?? Colors.orange,
      child: ListTile(
        title: const Text(
          "Today's Tasks",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text("$actionsCount actions pending"),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }

  Widget _weeklyProgressChart() {
    final completions = _getFlowCompletions();
    final today = DateTime.now();

    final last7Days = List.generate(
      7,
      (i) => today.subtract(Duration(days: 6 - i)),
    );
    final completedPerDay =
        last7Days.map((day) {
          return completions.where((d) => _isSameDate(d, day)).length;
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
            const Text(
              "Weekly Flow Completion",
              style: TextStyle(fontWeight: FontWeight.bold),
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
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 10,
                        height: completedPerDay[i] * 10.0,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(dayLabel),
                    ],
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
