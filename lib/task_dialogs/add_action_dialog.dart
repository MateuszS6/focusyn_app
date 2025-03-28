import 'package:flutter/material.dart';
import 'base_task_dialog.dart';

class AddActionDialog extends BaseTaskDialog {
  const AddActionDialog({super.key, required super.onAdd})
    : super(title: "Add Action");

  @override
  State<AddActionDialog> createState() => _AddActionDialogState();
}

class _AddActionDialogState extends BaseTaskDialogState<AddActionDialog> {
  String title = "";
  int priority = 1;
  int brainPoints = 1;

  @override
  Widget buildFields() {
    return Column(
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
            DropdownMenuItem(
              value: 4,
              child: Text("Not Urgent & Not Important"),
            ),
          ],
          onChanged: (val) => setState(() => priority = val!),
        ),
        TextField(
          decoration: InputDecoration(labelText: "Brain Points"),
          keyboardType: TextInputType.number,
          onChanged: (val) => brainPoints = int.tryParse(val) ?? 1,
        ),
        buildTagDropdown(),
      ],
    );
  }

  @override
  bool validate() => title.trim().isNotEmpty;

  @override
  Map<String, dynamic> buildData() => {
    "title": title,
    "priority": priority,
    "brainPoints": brainPoints,
    "tag": selectedTag,
  };
}
