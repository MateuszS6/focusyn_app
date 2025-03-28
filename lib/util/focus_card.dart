import 'package:flutter/material.dart';
import 'package:focusyn_app/app_data.dart';
import 'package:focusyn_app/pages/focus_task_page.dart';

class FocusCard extends StatelessWidget {
  final IconData icon;
  final String category;
  final String description;

  const FocusCard({
    super.key,
    required this.icon,
    required this.category,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _openTaskList(context, category),
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
                    "${AppData.instance.tasks[category]?.length ?? 0}",
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

  void _openTaskList(BuildContext context, String category) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => FocusTaskPage(category: category)),
    ).then((_) {
      // Trigger rebuild when returning from task page
      (context as Element).markNeedsBuild();
    });
  }
}
