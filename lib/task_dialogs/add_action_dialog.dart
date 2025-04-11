import 'package:flutter/material.dart';
import 'package:focusyn_app/data/app_data.dart';
import 'package:focusyn_app/data/keys.dart';
import 'package:focusyn_app/models/task_model.dart';
import 'package:focusyn_app/util/task_dialog.dart';

class AddActionDialog extends StatelessWidget {
  static const String _dialogTitle = "Add Action";
  static const String _titleLabel = "Title";
  static const String _priorityLabel = "Priority";
  static const String _brainPointsLabel = "Brain Points";
  static const String _tagLabel = "Tag";

  final void Function(TaskModel) onAdd;

  const AddActionDialog({super.key, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    String title = '';
    int priority = 1;
    int brainPoints = 5;
    String tag = Keys.all;
    final tags = AppData.instance.filters[Keys.actions] ?? [Keys.all];

    return TaskDialog(
      title: _dialogTitle,
      onAdd: onAdd,
      validateInput: () => title.trim().isNotEmpty,
      buildTask:
          () => TaskModel(
            title: title,
            priority: priority,
            brainPoints: brainPoints,
            tag: tag,
          ),
      fields: [
        TextField(
          decoration: const InputDecoration(labelText: _titleLabel),
          onChanged: (val) => title = val,
        ),
        DropdownButtonFormField<int>(
          value: priority,
          decoration: const InputDecoration(labelText: _priorityLabel),
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
          decoration: const InputDecoration(labelText: _brainPointsLabel),
          keyboardType: TextInputType.number,
          onChanged: (val) => brainPoints = int.tryParse(val) ?? 5,
        ),
        DropdownButtonFormField<String>(
          value: tag,
          decoration: const InputDecoration(labelText: _tagLabel),
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
