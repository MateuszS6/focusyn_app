import 'package:flutter/material.dart';
import 'package:focusyn_app/data/keys.dart';
import 'base_task_dialog.dart';

class AddFlowDialog extends BaseTaskDialog {
  const AddFlowDialog({super.key, required super.onAdd})
    : super(title: 'Add Flow');

  @override
  State<AddFlowDialog> createState() => _AddFlowDialogState();
}

class _AddFlowDialogState extends BaseTaskDialogState<AddFlowDialog> {
  String title = '';
  String date = '';
  String time = '';
  int duration = 15;
  String repeat = 'None';
  int brainPoints = 1;

  @override
  Widget buildFields() {
    return Column(
      children: [
        TextField(
          decoration: InputDecoration(labelText: 'Routine Title'),
          onChanged: (val) => title = val,
        ),
        TextField(
          decoration: InputDecoration(
            labelText: 'Start Date (e.g. 2024-04-01)',
          ),
          onChanged: (val) => date = val,
        ),
        TextField(
          decoration: InputDecoration(labelText: 'Time (e.g. 08:00 AM)'),
          onChanged: (val) => time = val,
        ),
        TextField(
          decoration: InputDecoration(
            labelText: 'Duration (minutes, default 15)',
          ),
          keyboardType: TextInputType.number,
          onChanged: (val) => duration = int.tryParse(val) ?? 15,
        ),
        DropdownButtonFormField<String>(
          value: repeat,
          decoration: InputDecoration(labelText: 'Repeat'),
          items: const [
            DropdownMenuItem(value: 'None', child: Text('None')),
            DropdownMenuItem(value: 'Daily', child: Text('Daily')),
            DropdownMenuItem(value: 'Weekly', child: Text('Weekly')),
          ],
          onChanged: (val) => setState(() => repeat = val!),
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
    Keys.title: title,
    Keys.date: date,
    Keys.time: time,
    Keys.duration: duration,
    Keys.repeat: repeat,
    Keys.tag: selectedTag,
  };
}
