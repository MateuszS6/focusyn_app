import 'package:flutter/material.dart';
import 'package:focusyn_app/constants/theme_icons.dart';
import 'package:focusyn_app/services/filter_service.dart';
import 'package:focusyn_app/constants/keys.dart';
import 'package:focusyn_app/models/task_model.dart';
import 'package:focusyn_app/utils/task_dialog.dart';

class FlowDialog extends StatefulWidget {
  static const String _dialogTitle = "Add Flow";
  static const String _editDialogTitle = "Edit Flow";
  static const String _titleLabel = "Title *";
  static const String _dateLabel = "Start Date";
  static const String _timeLabel = "Reminder Time";
  static const String _durationLabel = "Duration (minutes)";
  static const String _repeatLabel = "Repeat";
  static const String _brainPointsLabel = "Brain Points";
  static const String _listLabel = "List";

  final void Function(Task) onAdd;
  final String? defaultList;
  final Task? initialTask;

  const FlowDialog({
    super.key,
    required this.onAdd,
    this.defaultList,
    this.initialTask,
  });

  @override
  State<FlowDialog> createState() => _FlowDialogState();
}

class _FlowDialogState extends State<FlowDialog> {
  late String title;
  late DateTime selectedDate;
  late TimeOfDay selectedTime;
  late int duration;
  late String repeat;
  late int brainPoints;
  late String list;
  late final List<String> lists;

  // Controllers
  late TextEditingController titleController;
  late TextEditingController durationController;
  late TextEditingController brainPointsController;

  @override
  void initState() {
    super.initState();
    title = widget.initialTask?.text ?? '';
    selectedDate =
        widget.initialTask?.date != null
            ? DateTime.parse(widget.initialTask!.date!)
            : DateTime.now();
    selectedTime =
        widget.initialTask?.time != null
            ? TimeOfDay(
              hour: int.parse(widget.initialTask!.time!.split(':')[0]),
              minute: int.parse(widget.initialTask!.time!.split(':')[1]),
            )
            : const TimeOfDay(hour: 9, minute: 0);
    duration = widget.initialTask?.duration ?? 60;
    repeat = widget.initialTask?.repeat ?? 'Daily';
    brainPoints = widget.initialTask?.brainPoints ?? 5;
    lists = FilterService.filters[Keys.flows] ?? [Keys.all];
    list = widget.initialTask?.list ?? widget.defaultList ?? Keys.all;

    // Initialize controllers
    titleController = TextEditingController(
      text: widget.initialTask != null ? title : '',
    );
    durationController = TextEditingController(
      text: widget.initialTask != null ? duration.toString() : '',
    );
    brainPointsController = TextEditingController(
      text: widget.initialTask != null ? brainPoints.toString() : '',
    );
  }

  @override
  void dispose() {
    // Dispose controllers
    titleController.dispose();
    durationController.dispose();
    brainPointsController.dispose();
    super.dispose();
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
      title:
          widget.initialTask != null
              ? FlowDialog._editDialogTitle
              : FlowDialog._dialogTitle,
      onAdd: widget.onAdd,
      validateInput: () => title.trim().isNotEmpty,
      buildTask:
          () => Task(
            id:
                widget.initialTask?.id ??
                DateTime.now().millisecondsSinceEpoch.toString(),
            text: title,
            date: selectedDate.toIso8601String().split('T')[0],
            time: selectedTime.format(context),
            duration: duration,
            repeat: repeat,
            brainPoints: brainPoints,
            list: list,
            createdAt: widget.initialTask?.createdAt ?? DateTime.now(),
          ),
      fields: [
        TextField(
          decoration: inputDecoration.copyWith(
            labelText: FlowDialog._titleLabel,
            hintText: 'Describe the routine',
            prefixIcon: const Icon(ThemeIcons.text),
          ),
          controller: titleController,
          onChanged: (val) => setState(() => title = val),
        ),
        GestureDetector(
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
              labelText: FlowDialog._dateLabel,
              prefixIcon: const Icon(ThemeIcons.date),
            ),
            child: Text("${selectedDate.toLocal()}".split(' ')[0]),
          ),
        ),
        GestureDetector(
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
              labelText: FlowDialog._timeLabel,
              prefixIcon: const Icon(ThemeIcons.time),
            ),
            child: Text(selectedTime.format(context)),
          ),
        ),
        TextField(
          decoration: inputDecoration.copyWith(
            labelText: FlowDialog._durationLabel,
            hintText: "Default: 60",
            prefixIcon: const Icon(ThemeIcons.duration),
          ),
          keyboardType: TextInputType.number,
          controller: durationController,
          onChanged:
              (val) => setState(() => duration = int.tryParse(val) ?? 60),
        ),
        DropdownButtonFormField<String>(
          decoration: inputDecoration.copyWith(
            labelText: FlowDialog._repeatLabel,
            prefixIcon: const Icon(ThemeIcons.repeat),
          ),
          value: repeat,
          items:
              ['Daily', 'Weekly', 'Monthly']
                  .map(
                    (repeat) =>
                        DropdownMenuItem(value: repeat, child: Text(repeat)),
                  )
                  .toList(),
          onChanged: (val) => setState(() => repeat = val ?? 'Daily'),
        ),
        TextField(
          decoration: inputDecoration.copyWith(
            labelText: FlowDialog._brainPointsLabel,
            hintText: 'Default: 5',
            prefixIcon: const Icon(ThemeIcons.brainPoints),
          ),
          keyboardType: TextInputType.number,
          controller: brainPointsController,
          onChanged:
              (val) => setState(() => brainPoints = int.tryParse(val) ?? 5),
        ),
        DropdownButtonFormField<String>(
          decoration: inputDecoration.copyWith(
            labelText: FlowDialog._listLabel,
            prefixIcon: const Icon(ThemeIcons.tag),
          ),
          value: list,
          items:
              lists
                  .map(
                    (list) => DropdownMenuItem(value: list, child: Text(list)),
                  )
                  .toList(),
          onChanged: (val) => setState(() => list = val ?? Keys.all),
        ),
      ],
    );
  }
}
