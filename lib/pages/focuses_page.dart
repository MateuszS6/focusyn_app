import 'package:flutter/material.dart';
import 'package:focusyn_app/data/app_data.dart';
import 'package:focusyn_app/util/focus_card.dart';
import 'package:focusyn_app/util/my_app_bar.dart';

class FocusesPage extends StatefulWidget {
  const FocusesPage({super.key});

  @override
  State<FocusesPage> createState() => _FocusesPageState();
}

class _FocusesPageState extends State<FocusesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: 'Focuses',
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.more_vert))],
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 16, top: 16, right: 16),
        child: ListView(
          children: <Widget>[
            FocusCard(
              icon: Icons.whatshot_rounded,
              color: AppData.instance.colours['Actions']!['main']!,
              category: 'Actions',
              description: 'Your unscheduled to-do list',
            ),
            FocusCard(
              icon: Icons.event_repeat,
              color: AppData.instance.colours['Flows']!['main']!,
              category: 'Flows',
              description: 'Your routines and habits',
            ),
            FocusCard(
              icon: Icons.event_rounded,
              color: AppData.instance.colours['Moments']!['main']!,
              category: 'Moments',
              description: 'Your events and deadlines',
            ),
            FocusCard(
              icon: Icons.lightbulb_rounded,
              color: AppData.instance.colours['Thoughts']!['main']!,
              category: 'Thoughts',
              description: 'Your reflections for later',
            ),
          ],
        ),
      ),
    );
  }
}
