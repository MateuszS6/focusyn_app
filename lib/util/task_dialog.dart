import 'package:flutter/material.dart';

class TaskDialog extends StatefulWidget {
  final String title;
  final List<Widget> fields;
  final Map<String, dynamic> Function() buildData;
  final bool Function() validateInput;
  final void Function(Map<String, dynamic>) onAdd;

  const TaskDialog({
    super.key,
    required this.title,
    required this.fields,
    required this.buildData,
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
      content: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: widget.fields),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            if (widget.validateInput()) {
              widget.onAdd(widget.buildData());
              Navigator.pop(context);
            }
          },
          child: const Text("Add"),
        ),
      ],
    );
  }
}
