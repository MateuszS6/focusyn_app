import 'package:flutter/material.dart';
import 'package:focusyn_app/data/app_data.dart';
import 'package:focusyn_app/data/keys.dart';
import 'package:focusyn_app/task_dialogs/task_dialog.dart';

class AddMomentDialog extends StatelessWidget {
  final void Function(Map<String, dynamic>) onAdd;

  const AddMomentDialog({super.key, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    String title = '';
    String tag = Keys.all;
    String location = '';
    final tags = AppData.instance.filters[Keys.moments] ?? [Keys.all];
    DateTime date = DateTime.now();
    TimeOfDay time = TimeOfDay.now();
    Duration duration = const Duration(minutes: 30);

    return TaskDialog(
      title: "Add Moment",
      onAdd: onAdd,
      validate: () => title.trim().isNotEmpty,
      buildData:
          () => {
            Keys.title: title,
            Keys.tag: tag,
            Keys.date: date.toIso8601String().split('T').first,
            Keys.time: time.format(context),
            Keys.location: location,
            Keys.duration: duration.inMinutes,
          },
      fields: [
        TextField(
          decoration: const InputDecoration(labelText: "Moment Title"),
          onChanged: (val) => title = val,
        ),
        TextField(
          decoration: const InputDecoration(labelText: "Location (optional)"),
          onChanged: (val) => location = val,
        ),
        TextField(
          decoration: const InputDecoration(labelText: "Duration (minutes)"),
          keyboardType: TextInputType.number,
          onChanged:
              (val) => duration = Duration(minutes: int.tryParse(val) ?? 30),
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
