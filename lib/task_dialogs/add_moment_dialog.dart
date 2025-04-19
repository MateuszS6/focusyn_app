import 'package:flutter/material.dart';
import 'package:focusyn_app/constants/theme_icons.dart';
import 'package:focusyn_app/services/filter_service.dart';
import 'package:focusyn_app/constants/keys.dart';
import 'package:focusyn_app/models/task_model.dart';
import 'package:focusyn_app/utils/task_dialog.dart';

class AddMomentDialog extends StatefulWidget {
  static const String _dialogTitle = "Add Moment";
  static const String _titleLabel = "Title *";
  static const String _dateLabel = "Date";
  static const String _timeLabel = "Time";
  static const String _durationLabel = "Duration (minutes)";
  static const String _locationLabel = "Location";
  static const String _listLabel = "List";

  final void Function(Task) onAdd;
  final String? defaultList;

  const AddMomentDialog({super.key, required this.onAdd, this.defaultList});

  @override
  State<AddMomentDialog> createState() => _AddMomentDialogState();
}

class _AddMomentDialogState extends State<AddMomentDialog> {
  String title = '';
  String location = '';
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  Duration duration = const Duration(minutes: 30);
  String list = Keys.all;
  late final List<String> lists;

  @override
  void initState() {
    super.initState();
    lists = FilterService.filters[Keys.moments] ?? [Keys.all];
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
      title: AddMomentDialog._dialogTitle,
      onAdd: widget.onAdd,
      validateInput: () => title.trim().isNotEmpty,
      buildTask:
          () => Task(
            text: title,
            list: list,
            date: selectedDate.toIso8601String().split('T')[0],
            time: selectedTime.format(context),
            location: location.isNotEmpty ? location : null,
            duration: duration.inMinutes,
          ),
      fields: [
        TextField(
          decoration: inputDecoration.copyWith(
            labelText: AddMomentDialog._titleLabel,
            hintText: 'Describe the event',
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
              labelText: AddMomentDialog._dateLabel,
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
              labelText: AddMomentDialog._timeLabel,
              prefixIcon: const Icon(ThemeIcons.time),
            ),
            child: Text(selectedTime.format(context)),
          ),
        ),
        TextField(
          decoration: inputDecoration.copyWith(
            labelText: AddMomentDialog._durationLabel,
            hintText: 'Default: 30 minutes',
            prefixIcon: const Icon(ThemeIcons.duration),
          ),
          keyboardType: TextInputType.number,
          onChanged:
              (val) => setState(
                () => duration = Duration(minutes: int.tryParse(val) ?? 30),
              ),
        ),
        TextField(
          decoration: inputDecoration.copyWith(
            labelText: AddMomentDialog._locationLabel,
            hintText: 'Default: None',
            prefixIcon: const Icon(ThemeIcons.location),
          ),
          onChanged: (val) => setState(() => location = val),
        ),
        DropdownButtonFormField<String>(
          value: list,
          decoration: inputDecoration.copyWith(
            labelText: AddMomentDialog._listLabel,
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
