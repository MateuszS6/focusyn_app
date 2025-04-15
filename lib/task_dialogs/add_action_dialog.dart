import 'package:flutter/material.dart';
import 'package:focusyn_app/services/task_service.dart';
import 'package:focusyn_app/data/keys.dart';
import 'package:focusyn_app/models/task_model.dart';
import 'package:focusyn_app/utils/task_dialog.dart';

class AddActionDialog extends StatelessWidget {
  static const String _dialogTitle = "Add Action";
  static const String _titleLabel = "Title";
  static const String _priorityLabel = "Priority";
  static const String _brainPointsLabel = "Brain Points";
  static const String _tagLabel = "Tag";

  final void Function(Task) onAdd;

  const AddActionDialog({super.key, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    String title = '';
    int priority = 1;
    int brainPoints = 5;
    String tag = Keys.all;
    final tags = TaskService.instance.filters[Keys.actions] ?? [Keys.all];

    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade300),
    );

    final inputDecoration = InputDecoration(
      filled: true,
      fillColor: Colors.white,
      border: inputBorder,
      enabledBorder: inputBorder,
      focusedBorder: inputBorder,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );

    return TaskDialog(
      title: _dialogTitle,
      onAdd: onAdd,
      validateInput: () => title.trim().isNotEmpty,
      buildTask:
          () => Task(
            title: title,
            priority: priority,
            brainPoints: brainPoints,
            tag: tag,
          ),
      fields: [
        TextField(
          decoration: inputDecoration.copyWith(
            labelText: _titleLabel,
            prefixIcon: const Icon(Icons.title_rounded),
          ),
          onChanged: (val) => title = val,
        ),
        DropdownButtonFormField<int>(
          value: priority,
          decoration: inputDecoration.copyWith(
            labelText: _priorityLabel,
            prefixIcon: const Icon(Icons.priority_high_rounded),
          ),
          items: const [
            DropdownMenuItem(value: 1, child: Text("Urgent & Important")),
            DropdownMenuItem(value: 2, child: Text("Not Urgent but Important")),
            DropdownMenuItem(value: 3, child: Text("Urgent but Not Important")),
            DropdownMenuItem(
              value: 4,
              child: Text("Not Urgent & Not Important"),
            ),
          ],
          onChanged: (val) => priority = val ?? 1,
        ),
        TextField(
          decoration: inputDecoration.copyWith(
            labelText: _brainPointsLabel,
            prefixIcon: const Icon(Icons.psychology_rounded),
          ),
          keyboardType: TextInputType.number,
          onChanged: (val) => brainPoints = int.tryParse(val) ?? 5,
        ),
        DropdownButtonFormField<String>(
          value: tag,
          decoration: inputDecoration.copyWith(
            labelText: _tagLabel,
            prefixIcon: const Icon(Icons.label_rounded),
          ),
          items:
              tags
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
          onChanged: (val) => tag = val ?? Keys.all,
        ),
      ],
    );
  }
}
