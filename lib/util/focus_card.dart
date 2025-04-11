import 'package:flutter/material.dart';
import 'package:focusyn_app/data/app_data.dart';
import 'package:focusyn_app/pages/focus_task_page.dart';
import 'package:focusyn_app/util/tap_effect_card.dart';

class FocusCard extends StatelessWidget {
  static const double _avatarRadius = 30.0;
  static const double _iconSize = 30.0;
  static const double _titleFontSize = 24.0;
  static const double _countFontSize = 24.0;
  static const double _arrowIconSize = 30.0;
  static const double _spacing = 4.0;
  static const Color _defaultColor = Color(0xFFE0E0E0);
  static const Color _arrowColor = Colors.blue;
  static const EdgeInsets _margin = EdgeInsets.only(bottom: 16);
  static const double _height = 128.0;

  final IconData icon;
  final Color? color;
  final String category;
  final String description;

  const FocusCard({
    super.key,
    required this.icon,
    this.color = _defaultColor,
    required this.category,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return TapEffectCard(
      onTap: () => _openTaskList(context, category),
      margin: _margin,
      height: _height,
      child: ListTile(
        leading: CircleAvatar(
          radius: _avatarRadius,
          backgroundColor: color,
          child: Icon(
            icon,
            size: _iconSize,
            color: color != _defaultColor ? Colors.white : Colors.black,
          ),
        ),
        title: Text(
          category,
          style: const TextStyle(
            fontSize: _titleFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(description),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "${AppData.instance.tasks[category]?.length ?? 0}",
              style: const TextStyle(fontSize: _countFontSize),
            ),
            const SizedBox(width: _spacing),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: _arrowIconSize,
              color: _arrowColor,
            ),
          ],
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
