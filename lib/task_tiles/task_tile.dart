import 'package:flutter/material.dart';

class TaskTile extends StatefulWidget {
  final Widget? leading;
  final String text;
  final Function(String) onInlineEdit;
  final String? subtitle;
  final VoidCallback? onDelete;
  final VoidCallback? onDetailsEdit;
  final Color color;
  final EdgeInsets padding;

  const TaskTile({
    super.key,
    this.leading,
    required this.text,
    required this.onInlineEdit,
    this.subtitle,
    this.onDelete,
    this.onDetailsEdit,
    this.color = const Color(0xFFF5F5F5),
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  });

  @override
  State<TaskTile> createState() => _TaskTileState();
}

class _TaskTileState extends State<TaskTile> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: widget.color,
        borderRadius: BorderRadius.circular(16),
        child: ListTile(
          contentPadding: widget.padding,
          leading: widget.leading,
          title: GestureDetector(
            onTap: _showEditDialog,
            child: Text(
              widget.text,
              style: const TextStyle(fontSize: 18),
            ),
          ),
          subtitle: widget.subtitle != null
              ? Text(widget.subtitle!, style: const TextStyle(fontSize: 14))
              : null,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit_note_rounded),
                onPressed: widget.onDetailsEdit ??
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Edit task details coming soon")),
                      );
                    },
              ),
              if (widget.onDelete != null)
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded),
                  onPressed: widget.onDelete,
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditDialog() {
    String updated = widget.text;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit"),
        content: TextField(
          controller: TextEditingController(text: updated),
          onChanged: (val) => updated = val,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onInlineEdit(updated.trim());
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}
