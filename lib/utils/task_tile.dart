import 'package:flutter/material.dart';

class TaskTile extends StatefulWidget {
  final Widget? leading;
  final String text;
  final String? subtitle;
  final VoidCallback? onDelete;
  final Color color;
  final EdgeInsets padding;
  final TextStyle? subtitleStyle;
  final TextStyle? titleStyle;

  const TaskTile({
    super.key,
    this.leading,
    required this.text,
    this.subtitle,
    this.onDelete,
    this.color = const Color(0xFFF5F5F5),
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.subtitleStyle,
    this.titleStyle,
  });

  @override
  State<TaskTile> createState() => _TaskTileState();
}

class _TaskTileState extends State<TaskTile> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: widget.color,
      borderRadius: BorderRadius.circular(16),
      child: ListTile(
        contentPadding: widget.padding,
        leading: widget.leading,
        title: Text(
          widget.text,
          style: widget.titleStyle ?? const TextStyle(fontSize: 18),
        ),
        subtitle:
            widget.subtitle != null
                ? Text(
                  widget.subtitle!,
                  style: widget.subtitleStyle ?? const TextStyle(fontSize: 14),
                )
                : null,
      ),
    );
  }
}
