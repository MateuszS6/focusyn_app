import 'package:flutter/material.dart';
import 'package:focusyn_app/data/app_data.dart';
import 'package:focusyn_app/data/keys.dart';
import 'package:focusyn_app/models/task_model.dart';
import 'package:focusyn_app/util/task_dialog.dart';

class AddMomentDialog extends StatelessWidget {
  static const String _dialogTitle = "Add Moment";
  static const String _titleLabel = "Title";
  static const String _tagLabel = "Tag";

  final void Function(TaskModel) onAdd;

  const AddMomentDialog({super.key, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    String title = '';
    String tag = Keys.all;
    final tags = AppData.instance.filters[Keys.moments] ?? [Keys.all];

    return TaskDialog(
      title: _dialogTitle,
      onAdd: onAdd,
      validateInput: () => title.trim().isNotEmpty,
      buildTask: () => TaskModel(title: title, tag: tag),
      fields: [
        TextField(
          decoration: const InputDecoration(labelText: _titleLabel),
          onChanged: (val) => title = val,
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
