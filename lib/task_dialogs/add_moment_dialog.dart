import 'package:flutter/material.dart';
import 'package:focusyn_app/data/app_data.dart';
import 'package:focusyn_app/data/keys.dart';
import 'package:focusyn_app/models/task_model.dart';
import 'package:focusyn_app/util/task_dialog.dart';

class AddMomentDialog extends StatelessWidget {
  static const String _dialogTitle = "Add Moment";
  static const String _titleLabel = "Title";
  static const String _tagLabel = "Tag";

  final void Function(Task) onAdd;

  const AddMomentDialog({super.key, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    String title = '';
    String location = '';
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();
    String tag = Keys.all;
    final tags = AppData.instance.filters[Keys.moments] ?? [Keys.all];

    return TaskDialog(
      title: _dialogTitle,
      onAdd: onAdd,
      validateInput: () => title.trim().isNotEmpty,
      buildTask:
          () => Task(
            title: title,
            tag: tag,
            date: selectedDate.toIso8601String().split('T')[0],
            time: selectedTime.format(context),
            location: location.isNotEmpty ? location : null,
          ),
      fields: [
        TextField(
          decoration: const InputDecoration(labelText: _titleLabel),
          onChanged: (val) => title = val,
        ),
        ListTile(
          title: const Text("Date"),
          subtitle: Text("${selectedDate.toLocal()}".split(' ')[0]),
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: selectedDate,
              firstDate: DateTime.now().subtract(const Duration(days: 365)),
              lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
            );
            if (picked != null) selectedDate = picked;
          },
        ),
        ListTile(
          title: const Text("Time"),
          subtitle: Text(selectedTime.format(context)),
          onTap: () async {
            final picked = await showTimePicker(
              context: context,
              initialTime: selectedTime,
            );
            if (picked != null) selectedTime = picked;
          },
        ),
        TextField(
          decoration: const InputDecoration(
            labelText: "Location (optional)",
            hintText: "Enter location if applicable",
          ),
          onChanged: (val) => location = val,
        ),
        DropdownButtonFormField<String>(
          value: tag,
          decoration: const InputDecoration(labelText: _tagLabel),
          items:
              tags
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
          onChanged: (val) => tag = val ?? Keys.all,
        ),
      ],
    );
  }
}
