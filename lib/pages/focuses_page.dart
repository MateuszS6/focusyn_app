import 'package:flutter/material.dart';
import 'focus_task_page.dart'; // Import the FocusTaskPage class

class FocusesPage extends StatefulWidget {
  const FocusesPage({super.key});

  @override
  State<FocusesPage> createState() => _FocusesPageState();
}

class _FocusesPageState extends State<FocusesPage> {
  final Map<String, List<Map<String, dynamic>>> _tasks = {
    "Actions": [
    ],
    "Flows": [
    ],
    "Moments": [
    ],
    "Thoughts": [
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0),
          child: Text(
            'Organise your tasks, habits, and events',
            style: TextStyle(fontSize: 20.0, color: Colors.grey[600]),
          ),
        ),
        _buildFocusCard(
          Icons.category_rounded,
          'Actions',
          'Capture and organise tasks',
        ),
        _buildFocusCard(
          Icons.update_rounded,
          'Flows',
          'Build daily and weekly habits',
        ),
        _buildFocusCard(
          Icons.event_rounded,
          'Moments',
          'Upcoming events and deadlines',
        ),
        _buildFocusCard(
          Icons.lightbulb_outline_rounded,
          'Thoughts',
          'Capture ideas and thoughts',
        ),
      ],
    );
  }

  // Dynamic Focus Card
  Widget _buildFocusCard(IconData icon, String category, String description) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          _openTaskList(category);
        },
        child: Container(
          alignment: Alignment.center,
          margin: EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(20),
          ),
          child: ListTile(
            leading: CircleAvatar(
              radius: 30,
              backgroundColor: Colors.grey[300],
              child: Icon(icon, size: 30, color: Colors.black),
            ),
            title: Text(
              category,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(description),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "${_tasks[category]!.length}",
                  style: TextStyle(color: Colors.blue, fontSize: 24),
                ),
                SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 30,
                  color: Colors.blue,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}