import 'package:flutter/material.dart';

class AddTaskDialog extends StatefulWidget {
  final List<String> filters;
  final void Function(Map<String, dynamic>) onAdd;

  const AddTaskDialog({
    super.key,
    required this.filters,
    required this.onAdd,
  });

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  String title = "";
  int priority = 1;
  int brainPoints = 0;
  late String selectedTag;

  @override
  void initState() {
    super.initState();
    selectedTag = widget.filters.first;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Add Task"),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(labelText: "Task Title"),
              onChanged: (val) => title = val,
            ),
            DropdownButtonFormField<int>(
              value: priority,
              decoration: InputDecoration(labelText: "Eisenhower Priority"),
              items: const [
                DropdownMenuItem(value: 1, child: Text("Urgent & Important")),
                DropdownMenuItem(value: 2, child: Text("Not Urgent but Important")),
                DropdownMenuItem(value: 3, child: Text("Urgent but Not Important")),
                DropdownMenuItem(value: 4, child: Text("Not Urgent & Not Important")),
              ],
              onChanged: (val) => setState(() => priority = val!),
            ),
            TextField(
              decoration: InputDecoration(labelText: "Brain Points (Optional)"),
              keyboardType: TextInputType.number,
              onChanged: (val) => brainPoints = int.tryParse(val) ?? 0,
            ),
            DropdownButtonFormField<String>(
              value: selectedTag,
              decoration: InputDecoration(labelText: "Tag"),
              items: widget.filters.map((tag) => DropdownMenuItem(value: tag, child: Text(tag))).toList(),
              onChanged: (val) => setState(() => selectedTag = val!),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
        ElevatedButton(
          onPressed: () {
            if (title.isNotEmpty) {
              widget.onAdd({
                "title": title,
                "priority": priority,
                "brainPoints": brainPoints,
                "tag": selectedTag,
              });
              Navigator.pop(context);
            }
          },
          child: Text("Add"),
        ),
      ],
    );
  }
}