import 'package:flutter/material.dart';
import 'package:focusyn_app/data/app_data.dart';
import 'package:focusyn_app/data/brain_points_service.dart';
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
    final actions = AppData.instance.tasks["Actions"] ?? [];
    final today = DateTime.now();
    final dateStr = "${today.day}/${today.month}/${today.year}";

    return Scaffold(
      appBar: MyAppBar(
        title: 'Hub',
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
              _summaryCard(actions.length),
              const SizedBox(height: 16),
              _quoteCard(),
              const SizedBox(height: 16),
              _weeklyProgressPlaceholder(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _greetingCard(int points) {
    return Card(
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

  Widget _quoteCard() {
    final quote = _randomQuote();
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                "- ${quote["author"]}",
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

  Widget _weeklyProgressPlaceholder() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.green[50],
      child: SizedBox(
        height: 100,
        child: Center(child: Text("📊 Weekly progress chart coming soon")),
      ),
    );
  }
}
