import 'package:flutter/material.dart';

abstract class BaseTaskTile extends StatefulWidget {
  final Map<String, dynamic> task;
  final void Function(String newText) onEdit;

  const BaseTaskTile({super.key, required this.task, required this.onEdit});
}

abstract class BaseTaskTileState<T extends BaseTaskTile> extends State<T> {
  bool _isEditing = false;
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: getInitialText());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Override this to extract the editable field from `widget.task`
  String getInitialText();

  /// Override this to return the subtitle widget
  Widget buildSubtitle();

  /// Override this to build additional leading or trailing widgets
  Widget? buildLeading() => null;
  Widget? buildTrailing() => null;

  void _submitEdit() {
    final newText = _controller.text.trim();
    if (newText.isNotEmpty && newText != getInitialText()) {
      widget.onEdit(newText);
    }
    setState(() => _isEditing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      child: ListTile(
        leading: buildLeading(),
        trailing: buildTrailing(),
        title:
            _isEditing
                ? TextField(
                  controller: _controller,
                  autofocus: true,
                  onSubmitted: (_) => _submitEdit(),
                  onEditingComplete: _submitEdit,
                )
                : GestureDetector(
                  onTap: () => setState(() => _isEditing = true),
                  child: Text(
                    getInitialText(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
        subtitle: buildSubtitle(),
      ),
    );
  }
}
