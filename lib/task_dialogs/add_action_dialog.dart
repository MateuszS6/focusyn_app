import 'package:flutter/material.dart';
import 'package:focusyn_app/data/app_data.dart';
import 'package:focusyn_app/data/keys.dart';
import 'package:focusyn_app/task_dialogs/task_dialog.dart';

class AddActionDialog extends StatelessWidget {
  final void Function(Map<String, dynamic>) onAdd;

  const AddActionDialog({super.key, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    String title = '';
    int priority = 1;
    int brainPoints = 5;
    String tag = Keys.all;
    final tags = AppData.instance.filters[Keys.actions] ?? [Keys.all];

    return TaskDialog(
      title: "Add Action",
      onAdd: onAdd,
      validate: () => title.trim().isNotEmpty,
      buildData:
          () => {
            Keys.title: title,
            Keys.priority: priority,
            Keys.brainPoints: brainPoints,
            Keys.tag: tag,
          },
      fields: [
        TextField(
          decoration: const InputDecoration(labelText: "Title"),
          onChanged: (val) => title = val,
        ),
        DropdownButtonFormField<int>(
          value: priority,
          decoration: const InputDecoration(labelText: "Priority"),
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
          decoration: const InputDecoration(labelText: "Brain Points"),
          keyboardType: TextInputType.number,
          onChanged: (val) => brainPoints = int.tryParse(val) ?? 5,
        ),
        DropdownButtonFormField<String>(
          value: tag,
          decoration: const InputDecoration(labelText: "Tag"),
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
