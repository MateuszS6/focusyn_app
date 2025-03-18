import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';

class FocusesPage extends StatefulWidget {
  const FocusesPage({super.key});

  @override
  State<FocusesPage> createState() => _FocusesPageState();
}

class _FocusesPageState extends State<FocusesPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 32.0),
          child: Text(
            'Focuses',
            style: TextStyle(fontSize: 40.0, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: _buildFocusCard(
            Icons.checklist_rounded,
            'Actions',
            'Capture and organise tasks',
          ),
        ),
        Expanded(
          child: _buildFocusCard(
            Icons.timeline_rounded,
            'Flows',
            'Build daily and weekly habits',
          ),
        ),
        Expanded(
          child: _buildFocusCard(
            Icons.event_rounded,
            'Moments',
            'Upcoming events and deadlines',
          ),
        ),
        // _buildAddNewFocusCard(),
      ],
    );
  }

  // Helper Widget
  Widget _buildFocusCard(IconData icon, String title, String description) {
    return Container(
      margin: EdgeInsets.only(left: 8, top: 24, right: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200], // Placeholder colour
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, right: 24.0),
            child: Icon(icon, size: 48),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(title, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ]
      ),
    );
  }

  Widget _buildAddNewFocusCard() {
    return GestureDetector(
      onTap: () {
        // nothing yet
      },
      child: DottedBorder(
        color: Colors.grey,
        strokeWidth: 2,
        borderType: BorderType.RRect,
        radius: Radius.circular(20),
        dashPattern: [8, 4], // 8 is the dash, 4 is the gap
        child: SizedBox(
          height: 100,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add, color: Colors.grey),
                SizedBox(width: 8),
                Text(
                  'Add new focus area',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}