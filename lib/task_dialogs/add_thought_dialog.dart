import 'dart:math';

import 'package:flutter/material.dart';
import 'package:focusyn_app/data/app_data.dart';
import 'package:focusyn_app/data/keys.dart';
import 'package:focusyn_app/models/task_model.dart';
import 'package:focusyn_app/util/task_dialog.dart';

class AddThoughtDialog extends StatelessWidget {
  static const String _dialogTitle = "Add Thought";
  static const String _textLabel = "Text";
  static const String _tagLabel = "Tag";

  final void Function(TaskModel) onAdd;

  const AddThoughtDialog({super.key, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    String text = '';
    String tag = Keys.all;
    final tags = AppData.instance.filters[Keys.thoughts] ?? [Keys.all];

    return TaskDialog(
      title: _dialogTitle,
      onAdd: onAdd,
      validateInput: () => text.trim().isNotEmpty,
      buildTask:
          () => TaskModel(
            title: text.substring(0, min(text.length, 20)),
            text: text,
            tag: tag,
          ),
      fields: [
        TextField(
          decoration: const InputDecoration(labelText: _textLabel),
          maxLines: 5,
          onChanged: (val) => text = val,
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
