import 'package:flutter/material.dart';
import 'package:focusyn_app/constants/theme_icons.dart';
import 'package:focusyn_app/services/filter_service.dart';
import 'package:focusyn_app/constants/keys.dart';
import 'package:focusyn_app/models/task_model.dart';
import 'package:focusyn_app/utils/task_dialog.dart';

class ActionDialog extends StatelessWidget {
  static const String _dialogTitle = "Add Action";
  static const String _editDialogTitle = "Edit Action";
  static const String _titleLabel = "Title *";
  static const String _priorityLabel = "Priority";
  static const String _brainPointsLabel = "Brain Points";
  static const String _listLabel = "List";

  final void Function(Task) onAdd;
  final String? defaultList;
  final Task? initialTask;

  const ActionDialog({
    super.key,
    required this.onAdd,
    this.defaultList,
    this.initialTask,
  });

  @override
  Widget build(BuildContext context) {
    String title = initialTask?.title ?? '';
    int priority = initialTask?.priority ?? 1;
    int brainPoints = initialTask?.brainPoints ?? 5;
    String list = initialTask?.list ?? defaultList ?? Keys.all;
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
      title: initialTask != null ? _editDialogTitle : _dialogTitle,
      onAdd: onAdd,
      validateInput: () => title.trim().isNotEmpty,
      buildTask:
          () => Task(
            id:
                initialTask?.id ??
                DateTime.now().millisecondsSinceEpoch.toString(),
            title: title,
            priority: priority,
            brainPoints: brainPoints,
            list: list,
            createdAt: initialTask?.createdAt ?? DateTime.now(),
          ),
      fields: [
        TextField(
          decoration: inputDecoration.copyWith(
            labelText: _titleLabel,
            hintText: "Describe this task",
            prefixIcon: const Icon(ThemeIcons.text),
          ),
          onChanged: (val) => title = val.trim(),
          controller: TextEditingController(
            text: initialTask != null ? title : '',
          ),
        ),
        DropdownButtonFormField<int>(
          decoration: inputDecoration.copyWith(
            labelText: _priorityLabel,
            prefixIcon: const Icon(ThemeIcons.priority),
          ),
          value: priority,
          items: [
            DropdownMenuItem(value: 1, child: Text(Task.getPriorityText(1))),
            DropdownMenuItem(value: 2, child: Text(Task.getPriorityText(2))),
            DropdownMenuItem(value: 3, child: Text(Task.getPriorityText(3))),
            DropdownMenuItem(value: 4, child: Text(Task.getPriorityText(4))),
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
          controller: TextEditingController(
            text: initialTask != null ? brainPoints.toString() : '',
          ),
        ),
        DropdownButtonFormField<String>(
          decoration: inputDecoration.copyWith(
            labelText: _listLabel,
            prefixIcon: const Icon(ThemeIcons.tag),
          ),
          value: list,
          items:
              lists.map((list) {
                return DropdownMenuItem(value: list, child: Text(list));
              }).toList(),
          onChanged: (val) => list = val ?? Keys.all,
        ),
      ],
    );
  }
}
