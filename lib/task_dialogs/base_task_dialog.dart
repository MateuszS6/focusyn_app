import 'package:flutter/material.dart';
import 'package:focusyn_app/app_data.dart';

abstract class BaseTaskDialog extends StatefulWidget {
  final void Function(Map<String, dynamic>) onAdd;
  final String title;

  const BaseTaskDialog({
    super.key,
    required this.onAdd,
    required this.title,
  });
}

abstract class BaseTaskDialogState<T extends BaseTaskDialog> extends State<T> {
  late String selectedTag;
  late List<String> tags;

  @override
  void initState() {
    super.initState();
    final category = widget.title.contains("Thought")
        ? "Thoughts"
        : widget.title.contains("Moment")
            ? "Moments"
            : widget.title.contains("Flow")
                ? "Flows"
                : "Actions";

    tags = List.from(AppData.instance.filters[category] ?? ['All']);
    selectedTag = tags.first;
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
    return DropdownButtonFormField<String>(
      value: selectedTag,
      decoration: InputDecoration(labelText: "Tag"),
      items: tags
          .map((tag) => DropdownMenuItem(value: tag, child: Text(tag)))
          .toList(),
      onChanged: (val) => setState(() => selectedTag = val!),
    );
  }
}
