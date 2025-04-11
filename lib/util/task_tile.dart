import 'package:flutter/material.dart';

class TaskTile extends StatefulWidget {
  final Widget? leading;
  final String text;
  final Function(String) onInlineEdit;
  final String? subtitle;
  final VoidCallback? onDelete;
  final Color color;
  final EdgeInsets padding;

  const TaskTile({
    super.key,
    this.leading,
    required this.text,
    required this.onInlineEdit,
    this.subtitle,
    this.onDelete,
    this.color = const Color(0xFFF5F5F5),
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  });

  @override
  State<TaskTile> createState() => _TaskTileState();
}

class _TaskTileState extends State<TaskTile> {
  late final TextEditingController _editController;

  @override
  void initState() {
    super.initState();
    _editController = TextEditingController(text: widget.text);
  }

  @override
  void dispose() {
    _editController.dispose();
    super.dispose();
  }

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
            child: Text(widget.text, style: const TextStyle(fontSize: 18)),
          ),
          subtitle:
              widget.subtitle != null
                  ? Text(widget.subtitle!, style: const TextStyle(fontSize: 14))
                  : null,
          trailing:
              widget.onDelete != null
                  ? IconButton(
                    icon: const Icon(Icons.delete_rounded),
                    onPressed: widget.onDelete,
                  )
                  : null,
        ),
      ),
    );
  }

  void _showEditDialog() {
    _editController.text = widget.text;
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Edit"),
            content: TextField(controller: _editController, autofocus: true),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () {
                  if (!mounted) return;
                  Navigator.pop(context);
                  widget.onInlineEdit(_editController.text.trim());
                },
                child: const Text("Save"),
              ),
            ],
          ),
    );
  }
}
