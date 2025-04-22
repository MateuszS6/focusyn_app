import 'package:flutter/material.dart';
import 'package:focusyn_app/constants/theme_icons.dart';
import 'package:focusyn_app/services/filter_service.dart';
import 'package:focusyn_app/constants/keys.dart';
import 'package:focusyn_app/models/task_model.dart';
import 'package:focusyn_app/utils/task_dialog.dart';

/// A dialog widget for creating or editing moment tasks.
/// This dialog provides:
/// - Title input with validation
/// - Date and time selection
/// - Duration configuration
/// - Location information
/// - List categorization
class MomentDialog extends StatefulWidget {
  /// Title for the add moment dialog
  static const String _dialogTitle = 'Add Moment';

  /// Title for the edit moment dialog
  static const String _editDialogTitle = 'Edit Moment';

  /// Label for the title input field
  static const String _titleLabel = 'Title *';

  /// Label for the date input field
  static const String _dateLabel = 'Date';

  /// Label for the time input field
  static const String _timeLabel = 'Time';

  /// Label for the duration input field
  static const String _durationLabel = 'Duration (minutes)';

  /// Label for the location input field
  static const String _locationLabel = 'Location';

  /// Label for the list selection
  static const String _listLabel = 'List';

  /// Callback function when a moment task is created or edited
  final void Function(Task) onAdd;

  /// Default list name to pre-select
  final String? defaultList;

  /// Initial task data for editing
  final Task? initialTask;

  /// Creates a moment dialog with the specified properties.
  ///
  /// [onAdd] - Callback when a moment task is created or edited
  /// [defaultList] - Optional default list name
  /// [initialTask] - Optional initial task data for editing
  const MomentDialog({
    super.key,
    required this.onAdd,
    this.defaultList,
    this.initialTask,
  });

  @override
  State<MomentDialog> createState() => _MomentDialogState();
}

/// State class for managing the moment dialog's form data and UI.
class _MomentDialogState extends State<MomentDialog> {
  /// Current task title
  late String title;

  /// Selected date
  late DateTime selectedDate;

  /// Selected time
  late TimeOfDay selectedTime;

  /// Task duration in minutes
  late int duration;

  /// Task location
  late String location;

  /// Selected list name
  late String list;

  /// Available lists for selection
  late final List<String> lists;

  /// Controller for the title input field
  late TextEditingController titleController;

  /// Controller for the duration input field
  late TextEditingController durationController;

  /// Controller for the location input field
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
