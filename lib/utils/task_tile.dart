import 'package:flutter/material.dart';

/// A customizable tile widget for displaying task information.
/// This widget provides a consistent layout for task items with:
/// - Optional leading widget (e.g., icon)
/// - Title text
/// - Optional subtitle
/// - Long press gesture for editing
/// - Customizable styling
class TaskTile extends StatefulWidget {
  /// Optional widget to display at the start of the tile (e.g., icon)
  final Widget? leading;

  /// The main text to display in the tile
  final String text;

  /// Optional secondary text to display below the main text
  final String? subtitle;

  /// Callback function when the tile is long-pressed for editing
  final VoidCallback? onEdit;

  /// Callback function when the tile is deleted
  final VoidCallback? onDelete;

  /// Background color of the tile
  final Color color;

  /// Padding around the tile's content
  final EdgeInsets padding;

  /// Custom style for the subtitle text
  final TextStyle? subtitleStyle;

  /// Custom style for the title text
  final TextStyle? titleStyle;

  /// Currently selected list name
  final String? selectedList;

  /// Creates a task tile with customizable properties.
  ///
  /// [leading] - Optional widget at the start of the tile
  /// [text] - Required main text to display
  /// [subtitle] - Optional secondary text
  /// [onEdit] - Optional callback for long-press edit action
  /// [onDelete] - Optional callback for delete action
  /// [color] - Background color (default: light grey)
  /// [padding] - Content padding (default: horizontal 16, vertical 12)
  /// [subtitleStyle] - Optional custom subtitle text style
  /// [titleStyle] - Optional custom title text style
  /// [selectedList] - Optional currently selected list name
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
    this.selectedList,
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
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onLongPress: () => widget.onEdit?.call(),
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
