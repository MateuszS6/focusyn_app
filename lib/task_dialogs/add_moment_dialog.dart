import 'package:flutter/material.dart';
import 'package:focusyn_app/data/app_data.dart';
import 'package:focusyn_app/data/keys.dart';
import 'package:focusyn_app/util/task_dialog.dart';

class AddMomentDialog extends StatelessWidget {
  final void Function(Map<String, dynamic>) onAdd;

  const AddMomentDialog({super.key, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    String title = '';
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();
    Duration duration = const Duration(minutes: 30);
    String location = '';
    String tag = Keys.all;
    final tags = AppData.instance.filters[Keys.moments] ?? [Keys.all];

    return TaskDialog(
      title: "Add Moment",
      onAdd: onAdd,
      validateInput: () => title.trim().isNotEmpty,
      buildData:
          () => {
            Keys.title: title,
            Keys.date: selectedDate.toIso8601String().split('T').first,
            Keys.time: selectedTime.format(context),
            Keys.duration: duration.inMinutes,
            Keys.location: location,
            Keys.tag: tag,
          },
      fields: [
        TextField(
          decoration: const InputDecoration(labelText: "Moment Title"),
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
          decoration: const InputDecoration(labelText: "Duration (minutes)"),
          keyboardType: TextInputType.number,
          onChanged:
              (val) => duration = Duration(minutes: int.tryParse(val) ?? 30),
        ),
        TextField(
          decoration: const InputDecoration(labelText: "Location (optional)"),
          onChanged: (val) => location = val,
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
