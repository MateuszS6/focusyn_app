import 'package:flutter/material.dart';
import 'package:focusyn_app/data/app_data.dart';
import 'package:focusyn_app/data/keys.dart';
import 'package:focusyn_app/models/task_model.dart';
import 'package:focusyn_app/util/task_dialog.dart';

class AddFlowDialog extends StatefulWidget {
  static const String _dialogTitle = "Add Flow";
  static const String _titleLabel = "Title";
  static const String _tagLabel = "Tag";

  final void Function(Task) onAdd;

  const AddFlowDialog({super.key, required this.onAdd});

  @override
  State<AddFlowDialog> createState() => _AddFlowDialogState();
}

class _AddFlowDialogState extends State<AddFlowDialog> {
  String title = '';
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  Duration duration = const Duration(minutes: 15);
  String repeat = 'Daily';
  int brainPoints = 5;
  String tag = Keys.all;
  late final List<String> tags;

  @override
  void initState() {
    super.initState();
    tags = TaskService.instance.filters[Keys.flows] ?? [Keys.all];
  }

  @override
  Widget build(BuildContext context) {
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade300),
    );

    final inputDecoration = InputDecoration(
      filled: true,
      fillColor: Colors.white,
      border: inputBorder,
      enabledBorder: inputBorder,
      focusedBorder: inputBorder,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );

    return TaskDialog(
      title: AddFlowDialog._dialogTitle,
      onAdd: widget.onAdd,
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
          decoration: inputDecoration.copyWith(
            labelText: AddFlowDialog._titleLabel,
            prefixIcon: const Icon(Icons.title_rounded),
          ),
          onChanged: (val) => setState(() => title = val),
        ),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: selectedDate,
              firstDate: DateTime.now().subtract(const Duration(days: 365)),
              lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
            );
            if (picked != null) {
              setState(() => selectedDate = picked);
            }
          },
          child: InputDecorator(
            decoration: inputDecoration.copyWith(
              labelText: "Start Date",
              prefixIcon: const Icon(Icons.calendar_today_rounded),
            ),
            child: Text("${selectedDate.toLocal()}".split(' ')[0]),
          ),
        ),
        InkWell(
          onTap: () {
            showDialog(
              context: context,
              builder:
                  (context) => StatefulBuilder(
                    builder:
                        (context, setDialogState) => AlertDialog(
                          title: const Text('Set Time'),
                          content: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<int>(
                                  value: selectedTime.hour,
                                  decoration: inputDecoration.copyWith(
                                    labelText: 'Hour',
                                  ),
                                  items: List.generate(
                                    24,
                                    (index) => DropdownMenuItem(
                                      value: index,
                                      child: Text(
                                        index.toString().padLeft(2, '0'),
                                      ),
                                    ),
                                  ),
                                  onChanged: (value) {
                                    if (value != null) {
                                      setDialogState(() {
                                        setState(() {
                                          selectedTime = TimeOfDay(
                                            hour: value,
                                            minute: selectedTime.minute,
                                          );
                                        });
                                      });
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: DropdownButtonFormField<int>(
                                  value: selectedTime.minute,
                                  decoration: inputDecoration.copyWith(
                                    labelText: 'Minute',
                                  ),
                                  items: List.generate(
                                    60,
                                    (index) => DropdownMenuItem(
                                      value: index,
                                      child: Text(
                                        index.toString().padLeft(2, '0'),
                                      ),
                                    ),
                                  ),
                                  onChanged: (value) {
                                    if (value != null) {
                                      setDialogState(() {
                                        setState(() {
                                          selectedTime = TimeOfDay(
                                            hour: selectedTime.hour,
                                            minute: value,
                                          );
                                        });
                                      });
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                  ),
            );
          },
          child: InputDecorator(
            decoration: inputDecoration.copyWith(
              labelText: "Reminder Time",
              prefixIcon: const Icon(Icons.access_time_rounded),
            ),
            child: Text(selectedTime.format(context)),
          ),
        ),
        TextField(
          decoration: inputDecoration.copyWith(
            labelText: "Duration (minutes)",
            prefixIcon: const Icon(Icons.timer_rounded),
          ),
          keyboardType: TextInputType.number,
          onChanged:
              (val) => setState(
                () => duration = Duration(minutes: int.tryParse(val) ?? 15),
              ),
        ),
        DropdownButtonFormField<String>(
          value: repeat,
          decoration: inputDecoration.copyWith(
            labelText: "Repeat",
            prefixIcon: const Icon(Icons.repeat_rounded),
          ),
          items: const [
            DropdownMenuItem(value: 'Daily', child: Text('Daily')),
            DropdownMenuItem(value: 'Weekly', child: Text('Weekly')),
            DropdownMenuItem(value: 'Monthly', child: Text('Monthly')),
          ],
          onChanged: (val) => setState(() => repeat = val ?? 'Daily'),
        ),
        TextField(
          decoration: inputDecoration.copyWith(
            labelText: "Brain Points",
            prefixIcon: const Icon(Icons.psychology_rounded),
          ),
          keyboardType: TextInputType.number,
          onChanged:
              (val) => setState(() => brainPoints = int.tryParse(val) ?? 5),
        ),
        DropdownButtonFormField<String>(
          value: tag,
          decoration: inputDecoration.copyWith(
            labelText: AddFlowDialog._tagLabel,
            prefixIcon: const Icon(Icons.label_rounded),
          ),
          items:
              tags
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
          onChanged: (val) => setState(() => tag = val ?? Keys.all),
        ),
      ],
    );
  }
}
