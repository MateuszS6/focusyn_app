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
      {"title": "Complete Focusyn App", "priority": 1, "brainPoints": 10, "tag": "Work", "createdAt": DateTime.now().toIso8601String()},
      {"title": "Buy Groceries", "priority": 2, "brainPoints": 5, "tag": "Home", "createdAt": DateTime.now().toIso8601String()},
      {"title": "Call Mom", "priority": 3, "brainPoints": 3, "tag": "Home", "createdAt": DateTime.now().toIso8601String()},
      {"title": "Read a Book", "priority": 2, "brainPoints": 5, "createdAt": DateTime.now().toIso8601String()},
      {"title": "Go for a Run", "priority": 3, "brainPoints": 3, "createdAt": DateTime.now().toIso8601String()},
    ],
    "Flows": [
      {"title": "Morning Routine", "priority": 1, "brainPoints": 10, "tag": "Home", "createdAt": DateTime.now().toIso8601String()},
      {"title": "Evening Routine", "priority": 2, "brainPoints": 8, "tag": "Home", "createdAt": DateTime.now().toIso8601String()},
      {"title": "Workout Routine", "priority": 2, "brainPoints": 8, "tag": "Health", "createdAt": DateTime.now().toIso8601String()},
      {"title": "Weekly Review", "priority": 3, "brainPoints": 5, "createdAt": DateTime.now().toIso8601String()},
    ],
    "Moments": [
      {"title": "Birthday Party", "priority": 1, "brainPoints": 10, "tag": "Home", "createdAt": DateTime.now().toIso8601String()},
      {"title": "Meeting with Friends", "priority": 2, "brainPoints": 8, "tag": "School", "createdAt": DateTime.now().toIso8601String()},
      {"title": "Doctor's Appointment", "priority": 3, "brainPoints": 5, "tag": "Health", "createdAt": DateTime.now().toIso8601String()},
    ],
    "Thoughts": [
      {"text": "I should start reading more books", "createdAt": DateTime.now().toIso8601String()},
      {"text": "I need to call my parents more often", "createdAt": DateTime.now().toIso8601String()},
      {"text": "I should start working out", "createdAt": DateTime.now().toIso8601String()},
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
          'Your unscheduled to-do list',
        ),
        _buildFocusCard(
          Icons.update_rounded,
          'Flows',
          'Your routines and habits',
        ),
        _buildFocusCard(
          Icons.event_rounded,
          'Moments',
          'Your events and deadlines',
        ),
        _buildFocusCard(
          Icons.lightbulb_outline_rounded,
          'Thoughts',
          'Your reflections for later',
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
        child: Card(
          color: Colors.grey[100],
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          margin: EdgeInsets.only(bottom: 16),
          child: Center(
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
                    style: TextStyle(fontSize: 24),
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
      ),
    );
  }

  /// Opens the FocusTaskPage for the selected category
  void _openTaskList(String category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => FocusTaskPage(
              category: category,
              taskList: _tasks[category]!,
            ),
      ),
    );
  }
}
