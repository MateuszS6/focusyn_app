import 'package:flutter/material.dart';
import 'package:focusyn_app/data/app_data.dart';
import 'package:focusyn_app/data/keys.dart';
import 'package:focusyn_app/models/task_model.dart';
import 'package:focusyn_app/util/task_dialog.dart';

class AddFlowDialog extends StatelessWidget {
  static const String _dialogTitle = "Add Flow";
  static const String _titleLabel = "Title";
  static const String _tagLabel = "Tag";

  final void Function(Task) onAdd;

  const AddFlowDialog({super.key, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    String title = '';
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();
    Duration duration = const Duration(minutes: 15);
    String repeat = 'Daily';
    int brainPoints = 5;
    String tag = Keys.all;
    final tags = AppData.instance.filters[Keys.flows] ?? [Keys.all];

    return TaskDialog(
      title: _dialogTitle,
      onAdd: onAdd,
      validateInput: () => title.trim().isNotEmpty,
      buildTask:
          () => Task(
            title: title,
            tag: tag,
            brainPoints: brainPoints,
            duration: duration.inMinutes.toString(),
            date: selectedDate.toIso8601String().split('T')[0],
            time: selectedTime.format(context),
            repeat: repeat,
          ),
      fields: [
        TextField(
          decoration: const InputDecoration(labelText: _titleLabel),
          onChanged: (val) => title = val,
        ),
        ListTile(
          title: const Text("Start Date"),
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
          title: const Text("Reminder Time"),
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
          decoration: const InputDecoration(labelText: "Duration (minutes)"),
          keyboardType: TextInputType.number,
          onChanged:
              (val) => duration = Duration(minutes: int.tryParse(val) ?? 15),
        ),
        DropdownButtonFormField<String>(
          value: repeat,
          decoration: const InputDecoration(labelText: "Repeat"),
          items: const [
            DropdownMenuItem(value: 'Daily', child: Text("Daily")),
            DropdownMenuItem(value: 'Weekly', child: Text("Weekly")),
            DropdownMenuItem(value: 'Monthly', child: Text("Monthly")),
          ],
          onChanged: (val) => repeat = val ?? 'Daily',
        ),
        TextField(
          decoration: const InputDecoration(labelText: "Brain Points"),
          keyboardType: TextInputType.number,
          onChanged: (val) => brainPoints = int.tryParse(val) ?? 5,
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
