import 'package:flutter/material.dart';
import 'package:focusyn_app/constants/theme_icons.dart';
import 'package:focusyn_app/services/filter_service.dart';
import 'package:focusyn_app/constants/keys.dart';
import 'package:focusyn_app/models/task_model.dart';
import 'package:focusyn_app/utils/task_dialog.dart';

/// A dialog widget for creating or editing flow tasks.
/// This dialog provides:
/// - Title input with validation
/// - Date and time selection
/// - Duration configuration
/// - Repeat pattern selection
/// - Brain points assignment
/// - List categorization
class FlowDialog extends StatefulWidget {
  /// Title for the add flow dialog
  static const String _dialogTitle = 'Add Flow';

  /// Title for the edit flow dialog
  static const String _editDialogTitle = 'Edit Flow';

  /// Label for the title input field
  static const String _titleLabel = 'Title *';

  /// Label for the date input field
  static const String _dateLabel = 'Start Date';

  /// Label for the time input field
  static const String _timeLabel = 'Reminder Time';

  /// Label for the duration input field
  static const String _durationLabel = 'Duration (minutes)';

  /// Label for the repeat pattern selection
  static const String _repeatLabel = 'Repeat';

  /// Label for the brain points input field
  static const String _brainPointsLabel = 'Brain Points';

  /// Label for the list selection
  static const String _listLabel = 'List';

  /// Callback function when a flow task is created or edited
  final void Function(Task) onAdd;

  /// Default list name to pre-select
  final String? defaultList;

  /// Initial task data for editing
  final Task? initialTask;

  /// Creates a flow dialog with the specified properties.
  ///
  /// [onAdd] - Callback when a flow task is created or edited
  /// [defaultList] - Optional default list name
  /// [initialTask] - Optional initial task data for editing
  const FlowDialog({
    super.key,
    required this.onAdd,
    this.defaultList,
    this.initialTask,
  });

  @override
  State<FlowDialog> createState() => _FlowDialogState();
}

/// State class for managing the flow dialog's form data and UI.
class _FlowDialogState extends State<FlowDialog> {
  /// Current task title
  late String title;

  /// Selected start date
  late DateTime selectedDate;

  /// Selected reminder time
  late TimeOfDay selectedTime;

  /// Task duration in minutes
  late int duration;

  /// Selected repeat pattern
  late String repeat;

  /// Assigned brain points
  late int brainPoints;

  /// Selected list name
  late String list;

  /// Available lists for selection
  late final List<String> lists;

  /// Controller for the title input field
  late TextEditingController titleController;

  /// Controller for the duration input field
  late TextEditingController durationController;

  /// Controller for the brain points input field
  late TextEditingController brainPointsController;

  @override
  void initState() {
    super.initState();
    title = widget.initialTask?.title ?? '';
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
            title: title,
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
            hintText: 'Describe this routine',
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
            child: Text(selectedDate.toLocal().toString().split(' ')[0]),
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
            hintText: 'Default: 60',
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
