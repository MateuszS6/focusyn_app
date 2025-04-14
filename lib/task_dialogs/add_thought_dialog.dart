import 'package:flutter/material.dart';
import 'package:focusyn_app/data/app_data.dart';
import 'package:focusyn_app/data/keys.dart';
import 'package:focusyn_app/models/task_model.dart';
import 'package:focusyn_app/util/task_dialog.dart';

class AddThoughtDialog extends StatefulWidget {
  static const String _dialogTitle = "Add Thought";
  static const String _textLabel = "Text";
  static const String _tagLabel = "Tag";

  final void Function(Task) onAdd;

  const AddThoughtDialog({super.key, required this.onAdd});

  @override
  State<AddThoughtDialog> createState() => _AddThoughtDialogState();
}

class _AddThoughtDialogState extends State<AddThoughtDialog> {
  String text = '';
  String tag = Keys.all;
  late final List<String> tags;

  @override
  void initState() {
    super.initState();
    tags = AppData.instance.filters[Keys.thoughts] ?? [Keys.all];
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
      title: AddThoughtDialog._dialogTitle,
      onAdd: widget.onAdd,
      validateInput: () => text.trim().isNotEmpty,
      buildTask: () => Task(title: text, tag: tag, text: text),
      fields: [
        TextField(
          decoration: inputDecoration.copyWith(
            labelText: AddThoughtDialog._textLabel,
            prefixIcon: const Icon(Icons.lightbulb_rounded),
            alignLabelWithHint: true,
          ),
          maxLines: 5,
          onChanged: (val) => setState(() => text = val),
        ),
        DropdownButtonFormField<String>(
          value: tag,
          decoration: inputDecoration.copyWith(
            labelText: AddThoughtDialog._tagLabel,
            prefixIcon: const Icon(Icons.label_rounded),
          ),
          items:
              tags
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
          onChanged: (val) => setState(() => tag = val ?? Keys.all),
        ),
      ],
    );
  }
}
