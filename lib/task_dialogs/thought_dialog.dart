import 'package:flutter/material.dart';
import 'package:focusyn_app/constants/theme_icons.dart';
import 'package:focusyn_app/services/filter_service.dart';
import 'package:focusyn_app/constants/keys.dart';
import 'package:focusyn_app/models/task_model.dart';
import 'package:focusyn_app/utils/task_dialog.dart';

class ThoughtDialog extends StatelessWidget {
  static const String _dialogTitle = 'Add Thought';
  static const String _editDialogTitle = 'Edit Thought';
  static const String _titleLabel = 'Title *';
  static const String _listLabel = 'List';

  final void Function(Task) onAdd;
  final String? defaultList;
  final Task? initialTask;

  const ThoughtDialog({
    super.key,
    required this.onAdd,
    this.defaultList,
    this.initialTask,
  });

  @override
  Widget build(BuildContext context) {
    String title = initialTask?.title ?? '';
    String list = initialTask?.list ?? defaultList ?? Keys.all;
    final lists = FilterService.filters[Keys.thoughts] ?? [Keys.all];

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
      title: initialTask != null ? _editDialogTitle : _dialogTitle,
      onAdd: onAdd,
      validateInput: () => title.trim().isNotEmpty,
      buildTask:
          () => Task(
            id:
                initialTask?.id ??
                DateTime.now().millisecondsSinceEpoch.toString(),
            title: title,
            list: list,
            createdAt: initialTask?.createdAt ?? DateTime.now(),
          ),
      fields: [
        TextField(
          decoration: inputDecoration.copyWith(
            labelText: _titleLabel,
            hintText: 'Describe this thought',
            prefixIcon: const Icon(ThemeIcons.text),
          ),
          onChanged: (val) => title = val.trim(),
          controller: TextEditingController(
            text: initialTask != null ? title : '',
          ),
        ),
        DropdownButtonFormField<String>(
          decoration: inputDecoration.copyWith(
            labelText: _listLabel,
            prefixIcon: const Icon(ThemeIcons.tag),
          ),
          value: list,
          items:
              lists
                  .map(
                    (list) => DropdownMenuItem(value: list, child: Text(list)),
                  )
                  .toList(),
          onChanged: (val) => list = val ?? Keys.all,
        ),
      ],
    );
  }
}
