import 'package:flutter/material.dart';
import 'base_task_dialog.dart';

class AddMomentDialog extends BaseTaskDialog {
  const AddMomentDialog({
    super.key,
    required super.filters,
    required super.onAdd,
  }) : super(title: "Add Moment");

  @override
  State<AddMomentDialog> createState() => _AddMomentDialogState();
}

class _AddMomentDialogState extends BaseTaskDialogState<AddMomentDialog> {
  String title = "";
  String date = "";
  String time = "";
  String location = "";

  @override
  Widget buildFields() {
    return Column(
      children: [
        TextField(
          decoration: InputDecoration(labelText: "Event Title"),
          onChanged: (val) => title = val,
        ),
        TextField(
          decoration: InputDecoration(labelText: "Date (e.g. 2024-04-01)"),
          onChanged: (val) => date = val,
        ),
        TextField(
          decoration: InputDecoration(labelText: "Time (e.g. 10:00 AM)"),
          onChanged: (val) => time = val,
        ),
        TextField(
          decoration: InputDecoration(labelText: "Location (optional)"),
          onChanged: (val) => location = val,
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
    "date": date,
    "time": time,
    "location": location,
    "tag": selectedTag,
  };
}
