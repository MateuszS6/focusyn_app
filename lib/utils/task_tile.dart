import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TaskTile extends StatefulWidget {
  final Widget? leading;
  final String text;
  final String? subtitle;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final Color color;
  final EdgeInsets padding;
  final TextStyle? subtitleStyle;
  final TextStyle? titleStyle;
  final String? selectedFilter;

  const TaskTile({
    super.key,
    this.leading,
    required this.text,
    this.subtitle,
    this.onEdit,
    this.onDelete,
    this.color = const Color(0xFFF5F5F5),
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.subtitleStyle,
    this.titleStyle,
    this.selectedFilter,
  });

  @override
  State<TaskTile> createState() => _TaskTileState();

  static String getPriorityText(int priority) {
    switch (priority) {
      case 1:
        return 'Urgent, Important';
      case 2:
        return 'Not Urgent, Important';
      case 3:
        return 'Urgent, Not Important';
      case 4:
        return 'Not Urgent, Not Important';
      default:
        return 'Unknown Priority';
    }
  }

  static String formatDate(String? date) {
    if (date == null) return '';

    final inputDate = DateTime.tryParse(date);
    if (inputDate == null) return '';

    final now = DateTime.now();
    final difference = inputDate.difference(now).inDays;

    if (difference >= 0 && difference < 7) {
      // If within 7 days from now
      return DateFormat.EEEE().format(inputDate); // e.g., "Monday"
    } else if (inputDate.year == now.year) {
      // If within the same year
      return DateFormat.MMMd().format(inputDate); // e.g., "Apr 20"
    } else {
      // Else, just return the input date
      return date;
    }
  }
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
    return GestureDetector(
      onLongPress: () => widget.onEdit?.call(),
      child: Material(
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
                    style:
                        widget.subtitleStyle ?? const TextStyle(fontSize: 14),
                  )
                  : null,
        ),
      ),
    );
  }
}
