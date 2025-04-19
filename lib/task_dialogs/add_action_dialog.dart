import 'package:flutter/material.dart';
import 'package:focusyn_app/constants/theme_icons.dart';
import 'package:focusyn_app/services/filter_service.dart';
import 'package:focusyn_app/constants/keys.dart';
import 'package:focusyn_app/models/task_model.dart';
import 'package:focusyn_app/utils/task_dialog.dart';

class AddActionDialog extends StatelessWidget {
  static const String _dialogTitle = "Add Action";
  static const String _titleLabel = "Title *";
  static const String _priorityLabel = "Priority";
  static const String _brainPointsLabel = "Brain Points";
  static const String _listLabel = "List";

  final void Function(Task) onAdd;
  final String? defaultList;

  const AddActionDialog({super.key, required this.onAdd, this.defaultList});

  @override
  Widget build(BuildContext context) {
    String title = '';
    int priority = 1;
    int brainPoints = 5;
    String list = defaultList ?? Keys.all;
    final lists = FilterService.filters[Keys.actions] ?? [Keys.all];

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
            text: title,
            priority: priority,
            brainPoints: brainPoints,
            list: list,
          ),
      fields: [
        TextField(
          decoration: inputDecoration.copyWith(
            labelText: _titleLabel,
            hintText: 'Describe the task',
            prefixIcon: const Icon(ThemeIcons.text),
          ),
          onChanged: (val) => title = val,
        ),
        DropdownButtonFormField<int>(
          value: priority,
          decoration: inputDecoration.copyWith(
            labelText: _priorityLabel,
            hintText: 'Default: Urgent, Important',
            prefixIcon: const Icon(ThemeIcons.priority),
          ),
          items: const [
            DropdownMenuItem(value: 1, child: Text("Urgent, Important")),
            DropdownMenuItem(value: 2, child: Text("Not Urgent, Important")),
            DropdownMenuItem(value: 3, child: Text("Urgent, Not Important")),
            DropdownMenuItem(
              value: 4,
              child: Text("Not Urgent, Not Important"),
            ),
          ],
          onChanged: (val) => priority = val ?? 1,
        ),
        TextField(
          decoration: inputDecoration.copyWith(
            labelText: _brainPointsLabel,
            hintText: 'Default: 5',
            prefixIcon: const Icon(ThemeIcons.brainPoints),
          ),
          keyboardType: TextInputType.number,
          onChanged: (val) => brainPoints = int.tryParse(val) ?? 5,
        ),
        DropdownButtonFormField<String>(
          value: list,
          decoration: inputDecoration.copyWith(
            labelText: _listLabel,
            prefixIcon: const Icon(ThemeIcons.tag),
          ),
          items:
              lists
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
          onChanged: (val) => list = val ?? Keys.all,
        ),
      ],
    );
  }
}
