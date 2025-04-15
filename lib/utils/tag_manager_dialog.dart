import 'package:flutter/material.dart';

class TagManagerDialog extends StatefulWidget {
  final List<String> tags;
  final void Function(String oldTag, String newTag) onRename;
  final void Function(String tag) onDelete;
  final void Function(String tag)? onToggleHide;
  final void Function(List<String> newOrder)? onReorder;

  const TagManagerDialog({
    super.key,
    required this.tags,
    required this.onRename,
    required this.onDelete,
    required this.onToggleHide,
    required this.onReorder,
  });

  @override
  State<TagManagerDialog> createState() => _TagManagerDialogState();
}

class _TagManagerDialogState extends State<TagManagerDialog> {
  late List<String> _tags;
  late Map<String, bool> _editing;
  late Map<String, bool> _hidden;

  @override
  void initState() {
    super.initState();
    _tags = List<String>.from(widget.tags);
    _editing = {for (var tag in _tags) tag: false};
    _hidden = {for (var tag in _tags) tag: false};
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.all(16),
      title: Text("Manage Tags"),
      content: SizedBox(
        width: double.maxFinite,
        child: ReorderableListView(
          shrinkWrap: true,
          onReorder: (oldIndex, newIndex) {
            if (newIndex > oldIndex) newIndex--;
            setState(() {
              final tag = _tags.removeAt(oldIndex);
              _tags.insert(newIndex, tag);
            });
            if (widget.onReorder != null) {
              widget.onReorder!(_tags);
            }
          },
          children: _tags.map((tag) {
            final isEditing = _editing[tag]!;
            final controller = TextEditingController(text: tag);
            return ListTile(
              key: ValueKey(tag),
              leading: Icon(Icons.drag_handle_rounded),
              title: isEditing
                  ? TextField(
                      autofocus: true,
                      controller: controller,
                      onSubmitted: (newValue) {
                        if (newValue.isNotEmpty && newValue != tag) {
                          setState(() {
                            final index = _tags.indexOf(tag);
                            _tags[index] = newValue;
                            _editing.remove(tag);
                            _editing[newValue] = false;
                            _hidden[newValue] = _hidden[tag]!;
                            _hidden.remove(tag);
                          });
                          widget.onRename(tag, newValue);
                        }
                      },
                    )
                  : GestureDetector(
                      onTap: () => setState(() => _editing[tag] = true),
                      child: Text(tag),
                    ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      _hidden[tag]! ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                      color: _hidden[tag]! ? Colors.grey : Colors.black,
                    ),
                    onPressed: () {
                      setState(() {
                        _hidden[tag] = !_hidden[tag]!;
                      });
                      if (widget.onToggleHide != null) {
                        widget.onToggleHide!(tag);
                      }
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete_rounded),
                    onPressed: () {
                      setState(() {
                        _editing.remove(tag);
                        _hidden.remove(tag);
                        _tags.remove(tag);
                      });
                      widget.onDelete(tag);
                    },
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Close"),
        ),
      ],
    );
  }
}
