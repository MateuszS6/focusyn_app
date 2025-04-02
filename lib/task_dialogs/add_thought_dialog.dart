import 'package:flutter/material.dart';
import 'package:focusyn_app/data/app_data.dart';
import 'package:focusyn_app/data/keys.dart';
import 'package:focusyn_app/task_dialogs/task_dialog.dart';

class AddThoughtDialog extends StatelessWidget {
  final void Function(Map<String, dynamic>) onAdd;

  const AddThoughtDialog({super.key, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    String text = '';
    String tag = Keys.all;
    final tags = AppData.instance.filters[Keys.thoughts] ?? [Keys.all];

    return TaskDialog(
      title: "Add Thought",
      onAdd: onAdd,
      validateInput: () => text.trim().isNotEmpty,
      buildData: () => {Keys.text: text, Keys.tag: tag},
      fields: [
        TextField(
          maxLines: 5,
          minLines: 3,
          decoration: const InputDecoration(
            labelText: "Thought / Note",
            alignLabelWithHint: true,
          ),
          onChanged: (val) => text = val,
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
