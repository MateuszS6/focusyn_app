import 'package:flutter/material.dart';

class TaskTile extends StatefulWidget {
  final Map<String, dynamic> task;
  final VoidCallback onComplete;
  final void Function(String newTitle) onEdit;

  const TaskTile({
    super.key,
    required this.task,
    required this.onComplete,
    required this.onEdit,
  });

  @override
  State<TaskTile> createState() => _TaskTileState();
}

class _TaskTileState extends State<TaskTile> {
  bool _isEditing = false;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.task["title"]);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submitEdit() {
    final newTitle = _controller.text.trim();
    if (newTitle.isNotEmpty && newTitle != widget.task["title"]) {
      widget.onEdit(newTitle);
    }
    setState(() => _isEditing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[100],
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title:
            _isEditing
                ? TextField(
                  controller: _controller,
                  autofocus: true,
                  onSubmitted: (_) => _submitEdit(),
                  onEditingComplete: _submitEdit,
                )
                : GestureDetector(
                  onTap: () => setState(() => _isEditing = true),
                  child: Text(
                    widget.task["title"],
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
        subtitle: Text(
          "Priority: ${widget.task["priority"]} • Brain Points: ${widget.task["brainPoints"]}",
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        trailing: IconButton(
          icon: Icon(Icons.check_circle_outline, color: Colors.green),
          onPressed: widget.onComplete,
        ),
      ),
    );
  }
}
