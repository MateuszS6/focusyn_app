import 'package:flutter/material.dart';
import 'package:focusyn_app/constants/theme_icons.dart';
import 'package:focusyn_app/models/task_model.dart';
import 'package:focusyn_app/utils/my_scroll_shadow.dart';

/// A customizable dialog for creating or editing tasks.
/// This dialog provides:
/// - Fixed width and maximum height
/// - Scrollable content area with shadow
/// - Customizable form fields
/// - Validation and task creation callbacks
class TaskDialog extends StatefulWidget {
  /// Fixed width of the dialog
  static const double _dialogWidth = 400.0;

  /// Maximum height of the dialog
  static const double _maxDialogHeight = 500.0;

  /// Title displayed at the top of the dialog
  final String title;

  /// List of form fields to display in the dialog
  final List<Widget> fields;

  /// Function to create a Task object from the form data
  final Task Function() buildTask;

  /// Function to validate the form input
  final bool Function() validateInput;

  /// Callback function when a task is successfully created
  final void Function(Task) onAdd;

  /// Creates a task dialog with the specified properties.
  ///
  /// [title] - The title to display at the top of the dialog
  /// [fields] - List of form fields to display
  /// [buildTask] - Function to create a Task from form data
  /// [validateInput] - Function to validate form input
  /// [onAdd] - Callback when a task is created
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
            // Fixed header with title
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
            // Scrollable content area with shadow
            Expanded(
              child: MyScrollShadow(
                size: 8,
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
            // Fixed footer with action buttons
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Icon(ThemeIcons.cancel, size: 24),
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
                    child: const Icon(ThemeIcons.done, size: 24),
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
