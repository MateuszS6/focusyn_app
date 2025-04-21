import 'package:flutter/material.dart';
import 'package:focusyn_app/constants/theme_icons.dart';
import 'package:focusyn_app/services/filter_service.dart';
import 'package:focusyn_app/constants/keys.dart';
import 'package:focusyn_app/models/task_model.dart';
import 'package:focusyn_app/utils/task_dialog.dart';

class MomentDialog extends StatefulWidget {
  static const String _dialogTitle = 'Add Moment';
  static const String _editDialogTitle = 'Edit Moment';
  static const String _titleLabel = 'Title *';
  static const String _dateLabel = 'Date';
  static const String _timeLabel = 'Time';
  static const String _durationLabel = 'Duration (minutes)';
  static const String _locationLabel = 'Location';
  static const String _listLabel = 'List';

  final void Function(Task) onAdd;
  final String? defaultList;
  final Task? initialTask;

  const MomentDialog({
    super.key,
    required this.onAdd,
    this.defaultList,
    this.initialTask,
  });

  @override
  State<MomentDialog> createState() => _MomentDialogState();
}

class _MomentDialogState extends State<MomentDialog> {
  late String title;
  late DateTime selectedDate;
  late TimeOfDay selectedTime;
  late int duration;
  late String location;
  late String list;
  late final List<String> lists;

  // Controllers
  late TextEditingController titleController;
  late TextEditingController durationController;
  late TextEditingController locationController;

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
    location = widget.initialTask?.location ?? '';
    lists = [Keys.all]; // Start with 'All'
    final filterLists = FilterService.filters[Keys.moments];
    if (filterLists != null && filterLists.isNotEmpty) {
      lists.addAll(filterLists.where((l) => l != Keys.all));
    }
    // Ensure the selected list exists in the items
    final initialList =
        widget.initialTask?.list ?? widget.defaultList ?? Keys.all;
    list = lists.contains(initialList) ? initialList : Keys.all;

    // Initialize controllers
    titleController = TextEditingController(
      text: widget.initialTask != null ? title : '',
    );
    durationController = TextEditingController(
      text: widget.initialTask != null ? duration.toString() : '',
    );
    locationController = TextEditingController(
      text: widget.initialTask != null ? location : '',
    );
  }

  @override
  void dispose() {
    // Dispose controllers
    titleController.dispose();
    durationController.dispose();
    locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Ensure lists are initialized with at least 'All'
    if (lists.isEmpty) {
      setState(() {
        lists = [Keys.all];
      });
    }
    // Ensure selected list is valid
    if (!lists.contains(list)) {
      setState(() {
        list = Keys.all;
      });
    }

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
              ? MomentDialog._editDialogTitle
              : MomentDialog._dialogTitle,
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
            location: location,
            list: list,
            createdAt: widget.initialTask?.createdAt ?? DateTime.now(),
          ),
      fields: [
        TextField(
          decoration: inputDecoration.copyWith(
            labelText: MomentDialog._titleLabel,
            hintText: 'Describe this event',
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
              labelText: MomentDialog._dateLabel,
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
              labelText: MomentDialog._timeLabel,
              prefixIcon: const Icon(ThemeIcons.time),
            ),
            child: Text(selectedTime.format(context)),
          ),
        ),
        TextField(
          decoration: inputDecoration.copyWith(
            labelText: MomentDialog._durationLabel,
            hintText: 'Default: 60',
            prefixIcon: const Icon(ThemeIcons.duration),
          ),
          keyboardType: TextInputType.number,
          controller: durationController,
          onChanged:
              (val) => setState(() => duration = int.tryParse(val) ?? 60),
        ),
        TextField(
          decoration: inputDecoration.copyWith(
            labelText: MomentDialog._locationLabel,
            hintText: 'Default: None',
            prefixIcon: const Icon(ThemeIcons.location),
          ),
          controller: locationController,
          onChanged: (val) => setState(() => location = val),
        ),
        DropdownButtonFormField<String>(
          decoration: inputDecoration.copyWith(
            labelText: MomentDialog._listLabel,
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
