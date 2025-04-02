import 'package:flutter/material.dart';

class TaskTile extends StatelessWidget {
  final Widget? leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final Color color;
  final EdgeInsets padding;

  const TaskTile({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.color = const Color(0xFFF5F5F5),
    this.padding = const EdgeInsets.only(left: 16, top: 8, right: 16, bottom: 8),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(16),
        child: ListTile(
          contentPadding: padding,
          leading: leading,
          title: title,
          subtitle: subtitle,
          trailing: trailing,
        ),
      ),
    );
  }
}
