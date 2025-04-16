import 'package:flutter/material.dart';
import 'package:focusyn_app/services/task_service.dart';
import 'package:focusyn_app/pages/task_page.dart';

class FocusCard extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final String category;
  final String description;
  final VoidCallback? onUpdate;

  const FocusCard({
    super.key,
    required this.icon,
    this.color = Colors.grey,
    required this.category,
    required this.description,
    this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color?.withAlpha(13) ?? Colors.grey.shade50, Colors.white],
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
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: () => _openTaskList(context),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: color?.withAlpha(179),
                    child: Icon(icon, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category,
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    "${TaskService.tasks[category]?.length ?? 0}",
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openTaskList(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TaskPage(category: category)),
    ).then((_) {
      // Trigger rebuild when returning from task page
      if (onUpdate != null) onUpdate!();
    });
  }
}
