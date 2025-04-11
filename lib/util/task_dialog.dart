import 'package:flutter/material.dart';
import 'package:focusyn_app/models/task_model.dart';

class TaskDialog extends StatefulWidget {
  static const double _dialogWidth = 400.0;
  static const double _dialogHeight = 500.0;
  static const double _fieldSpacing = 16.0;
  static const double _buttonSpacing = 8.0;
  static const EdgeInsets _fieldPadding = EdgeInsets.only(
    bottom: _fieldSpacing,
  );

  final String title;
  final List<Widget> fields;
  final Task Function() buildTask;
  final bool Function() validateInput;
  final void Function(Task) onAdd;

  const TaskDialog({
    super.key,
    required this.title,
    required this.fields,
    required this.buildTask,
    required this.validateInput,
    required this.onAdd,
  });

  @override
  State<TaskDialog> createState() => _TaskDialogState();
}

class _TaskDialogState extends State<TaskDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: TaskDialog._dialogWidth,
        height: TaskDialog._dialogHeight,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children:
                widget.fields
                    .map(
                      (field) => Padding(
                        padding: TaskDialog._fieldPadding,
                        child: field,
                      ),
                    )
                    .toList(),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        const SizedBox(width: TaskDialog._buttonSpacing),
        ElevatedButton(
          onPressed: () {
            if (widget.validateInput()) {
              widget.onAdd(widget.buildTask());
              Navigator.pop(context);
            }
          },
          child: const Text("Add"),
        ),
      ],
    );
  }
}
