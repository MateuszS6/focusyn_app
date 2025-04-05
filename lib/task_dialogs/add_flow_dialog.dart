import 'package:flutter/material.dart';
import 'package:focusyn_app/data/app_data.dart';
import 'package:focusyn_app/data/keys.dart';
import 'package:focusyn_app/util/task_dialog.dart';

class AddFlowDialog extends StatelessWidget {
  final void Function(Map<String, dynamic>) onAdd;

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
      title: "Add Flow",
      onAdd: onAdd,
      validateInput: () => title.trim().isNotEmpty,
      buildData:
          () => {
            Keys.title: title,
            Keys.date: selectedDate.toIso8601String().split('T').first,
            Keys.time: selectedTime.format(context),
            Keys.duration: duration.inMinutes,
            Keys.repeat: repeat,
            Keys.brainPoints: brainPoints,
            Keys.tag: tag,
          },
      fields: [
        TextField(
          decoration: const InputDecoration(labelText: "Flow Title"),
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
          decoration: const InputDecoration(labelText: "Tag"),
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
