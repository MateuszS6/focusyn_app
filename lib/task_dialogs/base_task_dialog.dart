import 'package:flutter/material.dart';

abstract class BaseTaskDialog extends StatefulWidget {
  final List<String>? filters;
  final void Function(Map<String, dynamic>) onAdd;
  final String title;

  const BaseTaskDialog({
    super.key,
    required this.onAdd,
    this.filters,
    required this.title,
  });
}

abstract class BaseTaskDialogState<T extends BaseTaskDialog> extends State<T> {
  String selectedTag = "";

  @override
  void initState() {
    super.initState();
    if (widget.filters != null && widget.filters!.isNotEmpty) {
      selectedTag = widget.filters!.first;
    }
  }

  Widget buildFields(); // implemented in subclasses
  Map<String, dynamic> buildData(); // return final task data

  bool validate(); // must return true if ready to add

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(child: buildFields()),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            if (validate()) {
              widget.onAdd(buildData());
              Navigator.pop(context);
            }
          },
          child: Text("Add"),
        ),
      ],
    );
  }

  Widget buildTagDropdown() {
    if (widget.filters == null || widget.filters!.isEmpty) return SizedBox();
    return DropdownButtonFormField<String>(
      value: selectedTag,
      decoration: InputDecoration(labelText: "Tag"),
      items:
          widget.filters!
              .map((tag) => DropdownMenuItem(value: tag, child: Text(tag)))
              .toList(),
      onChanged: (val) => setState(() => selectedTag = val!),
    );
  }
}
