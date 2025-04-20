import 'package:flutter/material.dart';
import 'package:focusyn_app/constants/theme_icons.dart';
import 'package:focusyn_app/services/filter_service.dart';
import 'package:focusyn_app/constants/keys.dart';
import 'package:focusyn_app/models/task_model.dart';
import 'package:focusyn_app/utils/task_dialog.dart';

class ThoughtDialog extends StatefulWidget {
  static const String _dialogTitle = "Add Thought";
  static const String _textLabel = "Text *";
  static const String _listLabel = "List";

  final void Function(Task) onAdd;
  final String? defaultList;

  const ThoughtDialog({super.key, required this.onAdd, this.defaultList});

  @override
  State<ThoughtDialog> createState() => _ThoughtDialogState();
}

class _ThoughtDialogState extends State<ThoughtDialog> {
  String text = '';
  String list = Keys.all;
  late final List<String> lists;

  @override
  void initState() {
    super.initState();
    lists = FilterService.filters[Keys.thoughts] ?? [Keys.all];
    list = widget.defaultList ?? Keys.all;
  }

  @override
  Widget build(BuildContext context) {
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
      title: ThoughtDialog._dialogTitle,
      onAdd: widget.onAdd,
      validateInput: () => text.trim().isNotEmpty,
      buildTask: () => Task(text: text, list: list),
      fields: [
        TextField(
          decoration: inputDecoration.copyWith(
            labelText: ThoughtDialog._textLabel,
            hintText: 'Describe the thought or reflection for later',
            prefixIcon: const Icon(ThemeIcons.text),
            alignLabelWithHint: true,
          ),
          maxLines: 5,
          onChanged: (val) => setState(() => text = val),
        ),
        DropdownButtonFormField<String>(
          value: list,
          decoration: inputDecoration.copyWith(
            labelText: ThoughtDialog._listLabel,
            prefixIcon: const Icon(ThemeIcons.tag),
          ),
          items:
              lists
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
          onChanged: (val) => setState(() => list = val ?? Keys.all),
        ),
      ],
    );
  }
}
