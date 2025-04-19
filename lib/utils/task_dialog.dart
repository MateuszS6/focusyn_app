import 'package:flutter/material.dart';
import 'package:flutter_scroll_shadow/flutter_scroll_shadow.dart';
import 'package:focusyn_app/constants/theme_icons.dart';
import 'package:focusyn_app/models/task_model.dart';

class TaskDialog extends StatefulWidget {
  static const double _dialogWidth = 400.0;
  static const double _maxDialogHeight = 500.0;

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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      backgroundColor: Colors.white,
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
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            // Scrollable content
            Expanded(
              child: ScrollShadow(
                color: Colors.grey.shade300,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
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
            ),
            // Fixed footer
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Icon(ThemeIcons.close, size: 24),
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
                      minimumSize: const Size(44, 44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Icon(ThemeIcons.check, size: 24),
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
