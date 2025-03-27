import 'package:flutter/material.dart';
import 'base_task_dialog.dart';

class AddFlowDialog extends BaseTaskDialog {
  const AddFlowDialog({super.key, required super.filters, required super.onAdd})
    : super(title: "Add Flow");

  @override
  State<AddFlowDialog> createState() => _AddFlowDialogState();
}

class _AddFlowDialogState extends BaseTaskDialogState<AddFlowDialog> {
  String title = "";
  String dueDate = "";
  String time = "";
  String repeat = "None";

  @override
  Widget buildFields() {
    return Column(
      children: [
        TextField(
          decoration: InputDecoration(labelText: "Routine Title"),
          onChanged: (val) => title = val,
        ),
        TextField(
          decoration: InputDecoration(labelText: "Due Date (e.g. 2024-04-01)"),
          onChanged: (val) => dueDate = val,
        ),
        TextField(
          decoration: InputDecoration(labelText: "Time (e.g. 08:00 AM)"),
          onChanged: (val) => time = val,
        ),
        DropdownButtonFormField<String>(
          value: repeat,
          decoration: InputDecoration(labelText: "Repeat"),
          items: const [
            DropdownMenuItem(value: "None", child: Text("None")),
            DropdownMenuItem(value: "Daily", child: Text("Daily")),
            DropdownMenuItem(value: "Weekly", child: Text("Weekly")),
          ],
          onChanged: (val) => setState(() => repeat = val!),
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
    "dueDate": dueDate,
    "time": time,
    "repeat": repeat,
    "tag": selectedTag,
  };
}
