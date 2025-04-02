import 'package:flutter/material.dart';
import 'package:focusyn_app/data/app_data.dart';
import 'package:focusyn_app/data/keys.dart';
import 'package:focusyn_app/task_dialogs/task_dialog.dart';

class AddFlowDialog extends StatelessWidget {
  final void Function(Map<String, dynamic>) onAdd;

  const AddFlowDialog({super.key, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    String title = '';
    String tag = Keys.all;
    final tags = AppData.instance.filters[Keys.flows] ?? [Keys.all];
    TimeOfDay? time = TimeOfDay.now();
    String repeat = 'Daily';
    int brainPoints = 5;
    Duration duration = const Duration(minutes: 15);

    return TaskDialog(
      title: "Add Flow",
      onAdd: onAdd,
      validate: () => title.trim().isNotEmpty,
      buildData:
          () => {
            Keys.title: title,
            Keys.tag: tag,
            Keys.time: time.format(context),
            Keys.repeat: repeat,
            Keys.brainPoints: brainPoints,
            Keys.duration: duration.inMinutes,
          },
      fields: [
        TextField(
          decoration: const InputDecoration(labelText: "Flow Title"),
          onChanged: (val) => title = val,
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
        TextField(
          decoration: const InputDecoration(labelText: "Duration (minutes)"),
          keyboardType: TextInputType.number,
          onChanged:
              (val) => duration = Duration(minutes: int.tryParse(val) ?? 15),
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
