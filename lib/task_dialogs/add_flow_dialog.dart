import 'package:flutter/material.dart';
import 'package:focusyn_app/constants/theme_icons.dart';
import 'package:focusyn_app/services/filter_service.dart';
import 'package:focusyn_app/constants/keys.dart';
import 'package:focusyn_app/models/task_model.dart';
import 'package:focusyn_app/utils/task_dialog.dart';

class AddFlowDialog extends StatefulWidget {
  static const String _dialogTitle = "Add Flow";
  static const String _titleLabel = "Title *";
  static const String _dateLabel = "Start Date";
  static const String _timeLabel = "Reminder Time";
  static const String _durationLabel = "Duration (minutes)";
  static const String _repeatLabel = "Repeat";
  static const String _brainPointsLabel = "Brain Points";
  static const String _listLabel = "List";

  final void Function(Task) onAdd;
  final String? defaultList;

  const AddFlowDialog({super.key, required this.onAdd, this.defaultList});

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
  String list = Keys.all;
  late final List<String> lists;

  @override
  void initState() {
    super.initState();
    lists = FilterService.filters[Keys.flows] ?? [Keys.all];
    list = widget.defaultList ?? Keys.all;
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
            text: title,
            list: list,
            brainPoints: brainPoints,
            duration: duration.inMinutes,
            date: selectedDate.toIso8601String().split('T')[0],
            time: selectedTime.format(context),
            repeat: repeat,
          ),
      fields: [
        TextField(
          decoration: inputDecoration.copyWith(
            labelText: AddFlowDialog._titleLabel,
            hintText: 'Describe the routine',
            prefixIcon: const Icon(ThemeIcons.text),
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
              labelText: AddFlowDialog._dateLabel,
              prefixIcon: const Icon(ThemeIcons.date),
            ),
            child: Text("${selectedDate.toLocal()}".split(' ')[0]),
          ),
        ),
        InkWell(
          onTap: () async {
            final picked = await showTimePicker(
              context: context,
              initialTime: selectedTime,
            );
            if (picked != null) {
              setState(() => selectedTime = picked);
            }
          },
          child: InputDecorator(
            decoration: inputDecoration.copyWith(
              labelText: AddFlowDialog._timeLabel,
              prefixIcon: const Icon(ThemeIcons.time),
            ),
            child: Text(selectedTime.format(context)),
          ),
        ),
        TextField(
          decoration: inputDecoration.copyWith(
            labelText: AddFlowDialog._durationLabel,
            hintText: 'Default: 15 minutes',
            prefixIcon: const Icon(ThemeIcons.duration),
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
            labelText: AddFlowDialog._repeatLabel,
            hintText: 'Default: Daily',
            prefixIcon: const Icon(ThemeIcons.repeat),
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
            labelText: AddFlowDialog._brainPointsLabel,
            hintText: 'Default: 5',
            prefixIcon: const Icon(ThemeIcons.brainPoints),
          ),
          keyboardType: TextInputType.number,
          onChanged:
              (val) => setState(() => brainPoints = int.tryParse(val) ?? 5),
        ),
        DropdownButtonFormField<String>(
          value: list,
          decoration: inputDecoration.copyWith(
            labelText: AddFlowDialog._listLabel,
            prefixIcon: const Icon(ThemeIcons.tag),
          ),
          items:
              lists
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
          onChanged: (val) => setState(() => list = val ?? Keys.all),
        ),
      ],
    );
  }
}
