import 'package:flutter/material.dart';

class FocusesPage extends StatefulWidget {
  const FocusesPage({super.key});

  @override
  State<FocusesPage> createState() => _FocusesPageState();
}

class _FocusesPageState extends State<FocusesPage> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        Text(
          'Your Focuses',
          style: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 48.0),
        _buildFocusCard(
          'Actions',
          'Capture and organise tasks',
        ),
        _buildFocusCard(
          'Flows',
          'Build daily and weekly habits',
        ),
        _buildFocusCard(
          'Moments',
          'Upcoming events and deadlines',
        ),
      ],
    );
  }

  // Helper Widget
  Widget _buildFocusCard(String title, String description) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[200], // Placeholder color
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text(description, style: TextStyle(fontSize: 16, color: Colors.grey[600])),
        ],
      ),
    );
  }
