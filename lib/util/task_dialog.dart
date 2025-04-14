import 'package:flutter/material.dart';
import 'package:focusyn_app/models/task_model.dart';

class TaskDialog extends StatefulWidget {
  static const double _dialogWidth = 400.0;
  static const double _maxDialogHeight = 500.0;
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
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: TaskDialog._dialogWidth,
          maxHeight: TaskDialog._maxDialogHeight,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Fixed header
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                widget.title,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
            ),
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children:
                      widget.fields
                          .map(
                            (field) => Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: field,
                            ),
                          )
                          .toList(),
                ),
              ),
            ),
            // Fixed footer
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      if (widget.validateInput()) {
                        widget.onAdd(widget.buildTask());
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(100, 44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("Add"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
