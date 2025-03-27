import 'package:flutter/material.dart';
import 'base_task_dialog.dart';

class AddThoughtDialog extends BaseTaskDialog {
  const AddThoughtDialog({super.key, required super.onAdd})
    : super(title: 'New Thought');

  @override
  State<AddThoughtDialog> createState() => _AddThoughtDialogState();
}

class _AddThoughtDialogState extends BaseTaskDialogState<AddThoughtDialog> {
  String text = "";

  @override
  Widget buildFields() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Write your thought...',
        border: OutlineInputBorder(),
      ),
      minLines: 3,
      maxLines: 6,
      onChanged: (val) => text = val,
    );
  }

  @override
  bool validate() => text.trim().isNotEmpty;

  @override
  Map<String, dynamic> buildData() => {'text': text};
}
