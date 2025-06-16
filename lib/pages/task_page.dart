import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:focusyn_app/constants/theme_colours.dart';
import 'package:focusyn_app/constants/theme_icons.dart';
import 'package:focusyn_app/services/task_service.dart';
import 'package:focusyn_app/services/filter_service.dart';
import 'package:focusyn_app/constants/keys.dart';
import 'package:focusyn_app/models/task_model.dart';
import 'package:focusyn_app/task_dialogs/action_dialog.dart';
import 'package:focusyn_app/task_dialogs/flow_dialog.dart';
import 'package:focusyn_app/task_dialogs/moment_dialog.dart';
import 'package:focusyn_app/task_dialogs/thought_dialog.dart';
import 'package:focusyn_app/task_tiles/action_tile.dart';
import 'package:focusyn_app/task_tiles/flow_tile.dart';
import 'package:focusyn_app/task_tiles/moment_tile.dart';
import 'package:focusyn_app/task_tiles/thought_tile.dart';
import 'package:focusyn_app/utils/filter_row.dart';
import 'package:focusyn_app/utils/my_scroll_shadow.dart';

/// A page that displays and manages tasks for a specific category.
///
/// This page provides functionality for:
/// - Viewing tasks in different categories (Actions, Flows, Moments, Thoughts)
/// - Filtering tasks by lists
/// - Sorting tasks by various criteria
/// - Adding, editing, and deleting tasks
/// - Managing task lists
///
/// The page integrates with [TaskService] for task management
/// and [FilterService] for list management.
class TaskPage extends StatefulWidget {
  /// Creates a task page for the specified category.
  ///
  /// [category] must be one of: 'Actions', 'Flows', 'Moments', or 'Thoughts'.
  const TaskPage({super.key, required this.category});

  /// The category of tasks to display and manage.
  final String category;

  @override
  State<TaskPage> createState() => _TaskPageState();
}

/// The state class for [TaskPage].
///
/// Manages the task list state and provides methods for:
/// - Filtering and sorting tasks
/// - Task operations (add, edit, delete)
/// - List management
/// - UI state management
class _TaskPageState extends State<TaskPage> {
  /// The list of tasks for the current category.
  late List<Task> _tasks;

  /// The list of available filters/lists for the current category.
  late List<String> _filters;

  /// The currently selected filter/list.
  String _selectedFilter = Keys.all;

  /// The current sorting criteria.
  String? _sortBy;

  /// The ID of the last edited task, used for highlighting.
  String? _lastEditedTaskId;

  /// Gets the filtered and sorted list of tasks.
  ///
  /// Filters tasks by the selected list and sorts them according to [_sortBy].
  /// The sorting criteria vary by category:
  /// - Actions: Priority, Brain Points, Alphabetical, Creation Date
  /// - Flows: Date, Brain Points, Alphabetical, Creation Date
  /// - Moments: Date, Alphabetical, Creation Date
  /// - Thoughts: Alphabetical, Creation Date
  List<Task> get _filteredTasks {
    var filtered =
        _selectedFilter == Keys.all
            ? _tasks
            : _tasks.where((task) => task.list == _selectedFilter).toList();

    // Sort tasks
    filtered.sort((a, b) {
      switch (_sortBy) {
        case 'Priority':
          final priorityCompare = (a.priority!).compareTo(b.priority!);
          if (priorityCompare != 0) return priorityCompare;
          break;
        case 'Brain Points':
          final bpCompare = (a.brainPoints!).compareTo(b.brainPoints!);
          if (bpCompare != 0) return bpCompare;
          break;
        case 'Alphabetical':
          final aText = a.title;
          final bText = b.title;
          final titleCompare = aText.toLowerCase().compareTo(
            bText.toLowerCase(),
          );
          if (titleCompare != 0) return titleCompare;
          break;
        case 'Date':
          if (widget.category == Keys.flows ||
              widget.category == Keys.moments) {
            final dateCompare = (a.date!).compareTo(b.date!);
            if (dateCompare != 0) return dateCompare;
          }
          break;
      }
      // Default to creation date order
      return DateTime.parse(
        a.createdAt.toString(),
      ).compareTo(DateTime.parse(b.createdAt.toString()));
    });

    return filtered;
  }

  /// Initializes the state of the task page.
  ///
  /// Loads tasks and filters for the current category from [TaskService] and [FilterService].
  /// Ensures the 'All' filter is always present in the list.
  @override
  void initState() {
    super.initState();
    _tasks = TaskService.tasks[widget.category]!;
    _filters = FilterService.filters[widget.category]!;

    // Ensure 'All' tag is always present
    if (!_filters.contains(Keys.all)) {
      _filters.insert(0, Keys.all);
      FilterService.updateFilters(widget.category, _filters);
    }
  }

  /// Builds the task page UI.
  ///
  /// The UI consists of:
  /// - A header with back button, category title, and sort button
  /// - A filter row for selecting lists
  /// - A list of tasks or empty state
  /// - A floating action button for adding tasks
  @override
  Widget build(BuildContext context) {
    final color = switch (widget.category) {
      Keys.actions => ThemeColours.actionsMain,
      Keys.flows => ThemeColours.flowsMain,
      Keys.moments => ThemeColours.momentsMain,
      Keys.thoughts => ThemeColours.thoughtsMain,
      _ => ThemeColours.taskMain,
    };

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(ThemeIcons.back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.category,
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(ThemeIcons.sort),
                    onPressed: _showSortDialog,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              FilterRow(
                category: widget.category,
                filters: _filters,
                selected: _selectedFilter,
                onSelect: (filter) => setState(() => _selectedFilter = filter),
                onAdd: _openAddTagDialog,
                onDelete: (tag) async {
                  setState(() {
                    _filters.remove(tag);
                    _tasks.removeWhere((task) => task.list == tag);
                    if (_selectedFilter == tag) _selectedFilter = Keys.all;
                  });
                  // Update both tasks and filters in the cloud
                  await TaskService.updateTasks(widget.category, _tasks);
                  await FilterService.updateFilters(widget.category, _filters);
                },
              ),
              const SizedBox(height: 24),
              Expanded(
                child:
                    _filteredTasks.isEmpty
                        ? _buildEmptyState()
                        : _buildTaskList(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton:
          _filteredTasks.isEmpty
              ? null
              : FloatingActionButton(
                onPressed: _showAddDialog,
                backgroundColor: color,
                elevation: 2,
                shape: const CircleBorder(),
                child: const Icon(
                  ThemeIcons.add,
                  size: 32,
                  color: Colors.white,
                ),
              ),
    );
  }

  /// Shows a dialog for selecting the sorting criteria.
  ///
  /// The available options depend on the task category:
  /// - Actions: Priority, Brain Points, Alphabetical, Creation Date
  /// - Flows: Date, Brain Points, Alphabetical, Creation Date
  /// - Moments: Date, Alphabetical, Creation Date
  /// - Thoughts: Alphabetical, Creation Date
  void _showSortDialog() {
    List<RadioListTile> options = [];

    switch (widget.category) {
      case Keys.actions:
        _sortBy ??= 'Priority';
        options = [
          RadioListTile(
            title: const Text('Priority'),
            value: 'Priority',
            groupValue: _sortBy,
            onChanged: (value) {
              setState(() => _sortBy = value.toString());
              Navigator.pop(context);
            },
          ),
          RadioListTile(
            title: const Text('Brain Points'),
            value: 'Brain Points',
            groupValue: _sortBy,
            onChanged: (value) {
              setState(() => _sortBy = value.toString());
              Navigator.pop(context);
            },
          ),
          RadioListTile(
            title: const Text('Alphabetical'),
            value: 'Alphabetical',
            groupValue: _sortBy,
            onChanged: (value) {
              setState(() => _sortBy = value.toString());
              Navigator.pop(context);
            },
          ),
          RadioListTile(
            title: const Text('Creation Date'),
            value: 'Date',
            groupValue: _sortBy,
            onChanged: (value) {
              setState(() => _sortBy = value.toString());
              Navigator.pop(context);
            },
          ),
        ];
        break;

      case Keys.flows:
        _sortBy ??= 'Date';
        options = [
          RadioListTile(
            title: const Text('Date'),
            value: 'Date',
            groupValue: _sortBy,
            onChanged: (value) {
              setState(() => _sortBy = value.toString());
              Navigator.pop(context);
            },
          ),
          RadioListTile(
            title: const Text('Brain Points'),
            value: 'Brain Points',
            groupValue: _sortBy,
            onChanged: (value) {
              setState(() => _sortBy = value.toString());
              Navigator.pop(context);
            },
          ),
          RadioListTile(
            title: const Text('Alphabetical'),
            value: 'Alphabetical',
            groupValue: _sortBy,
            onChanged: (value) {
              setState(() => _sortBy = value.toString());
              Navigator.pop(context);
            },
          ),
          RadioListTile(
            title: const Text('Creation Date'),
            value: 'Creation Date',
            groupValue: _sortBy,
            onChanged: (value) {
              setState(() => _sortBy = value.toString());
              Navigator.pop(context);
            },
          ),
        ];
        break;

      case Keys.moments:
        _sortBy ??= 'Date';
        options = [
          RadioListTile(
            title: const Text('Date'),
            value: 'Date',
            groupValue: _sortBy,
            onChanged: (value) {
              setState(() => _sortBy = value.toString());
              Navigator.pop(context);
            },
          ),
          RadioListTile(
            title: const Text('Alphabetical'),
            value: 'Alphabetical',
            groupValue: _sortBy,
            onChanged: (value) {
              setState(() => _sortBy = value.toString());
              Navigator.pop(context);
            },
          ),
          RadioListTile(
            title: const Text('Creation Date'),
            value: 'Creation Date',
            groupValue: _sortBy,
            onChanged: (value) {
              setState(() => _sortBy = value.toString());
              Navigator.pop(context);
            },
          ),
        ];
        break;

      case Keys.thoughts:
        _sortBy ??= 'Creation Date';
        options = [
          RadioListTile(
            title: const Text('Alphabetical'),
            value: 'Alphabetical',
            groupValue: _sortBy,
            onChanged: (value) {
              setState(() => _sortBy = value.toString());
              Navigator.pop(context);
            },
          ),
          RadioListTile(
            title: const Text('Creation Date'),
            value: 'Creation Date',
            groupValue: _sortBy,
            onChanged: (value) {
              setState(() => _sortBy = value.toString());
              Navigator.pop(context);
            },
          ),
        ];
        break;
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Sort Tasks'),
            content: Column(mainAxisSize: MainAxisSize.min, children: options),
          ),
    );
  }

  /// Builds the empty state widget when no tasks are present.
  ///
  /// Shows a centered message with:
  /// - Category-specific icon
  /// - Empty state title
  /// - Empty state message
  /// - Add button
  Widget _buildEmptyState() {
    final color = switch (widget.category) {
      Keys.actions => ThemeColours.actionsMain,
      Keys.flows => ThemeColours.flowsMain,
      Keys.moments => ThemeColours.momentsMain,
      Keys.thoughts => ThemeColours.thoughtsMain,
      _ => ThemeColours.taskMain,
    };
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: color.withAlpha(26),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(_getEmptyStateIcon(), size: 64, color: color),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _getEmptyStateTitle(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getEmptyStateMessage(),
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: _showAddDialog,
                      icon: const Icon(ThemeIcons.add, color: Colors.white),
                      label: Text(
                        'Add ${widget.category.substring(0, widget.category.length - 1)}',
                        style: const TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Builds the list of tasks.
  ///
  /// Uses [MyScrollShadow] for visual feedback and separates items with spacing.
  Widget _buildTaskList() {
    return MyScrollShadow(
      child: ListView.separated(
        itemCount: _filteredTasks.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        padding: const EdgeInsets.symmetric(vertical: 4),
        itemBuilder: (_, index) => _buildTaskTile(_filteredTasks[index]),
      ),
    );
  }

  /// Builds a task tile with appropriate actions.
  ///
  /// The tile type depends on the category:
  /// - Actions: [ActionTile]
  /// - Flows: [FlowTile]
  /// - Moments: [MomentTile]
  /// - Thoughts: [ThoughtTile]
  ///
  /// Includes swipe-to-delete functionality and highlights recently edited tasks.
  Widget _buildTaskTile(Task task) {
    final key = ValueKey(task);
    final isLastEdited = task.id == _lastEditedTaskId;

    Widget tile;
    List<SlidableAction> actions = [
      SlidableAction(
        onPressed: (_) => _removeTask(task),
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFFE53935),
        icon: ThemeIcons.delete,
        padding: EdgeInsets.zero,
      ),
    ];

    switch (widget.category) {
      case Keys.actions:
        tile = ActionTile(
          key: key,
          task: task,
          onEdit: () => _showEditDialog(task),
          onComplete: () => _removeTask(task),
          onDelete: () => _removeTask(task),
          selectedList: _selectedFilter,
        );
        break;

      case Keys.flows:
        tile = FlowTile(
          key: key,
          task: task,
          onComplete: (updatedTask) {
            setState(() {
              final index = _tasks.indexWhere((t) => t.id == task.id);
              if (index != -1) {
                _tasks[index] = updatedTask;
                _lastEditedTaskId = task.id;
              }
            });
            _updateTask(task);
          },
          onDelete: () => _removeTask(task),
          selectedList: _selectedFilter,
          onEdit: () => _showEditDialog(task),
        );
        break;

      case Keys.moments:
        tile = MomentTile(
          key: key,
          task: task,
          onDelete: () => _removeTask(task),
          selectedList: _selectedFilter,
          onEdit: () => _showEditDialog(task),
        );
        break;

      case Keys.thoughts:
        tile = ThoughtTile(
          key: key,
          task: task,
          onDelete: () => _removeTask(task),
          selectedList: _selectedFilter,
          onEdit: () => _showEditDialog(task),
        );
        break;

      default:
        return const SizedBox.shrink();
    }

    return Slidable(
      key: key,
      endActionPane: ActionPane(
        motion: const BehindMotion(),
        extentRatio: 0.15,
        dismissible: DismissiblePane(onDismissed: () => _removeTask(task)),
        children: actions,
      ),
      child: Container(
        decoration:
            isLastEdited
                ? BoxDecoration(
                  border: Border.all(color: ThemeColours.taskMain, width: 1.5),
                  borderRadius: BorderRadius.circular(16),
                )
                : null,
        child: tile,
      ),
    );
  }

  /// Updates a task in the list and syncs with the cloud.
  ///
  /// [task] is the updated task to save.
  Future<void> _updateTask(Task task) async {
    setState(() {
      _lastEditedTaskId = task.id;
    });
    await TaskService.updateTasks(widget.category, _tasks);
  }

  /// Removes a task from the list and syncs with the cloud.
  ///
  /// [task] is the task to remove.
  Future<void> _removeTask(Task task) async {
    setState(() {
      _tasks.remove(task);
      if (_lastEditedTaskId == task.id) {
        _lastEditedTaskId = null;
      }
    });
    await TaskService.updateTasks(widget.category, _tasks);
  }

  /// Shows the add task dialog for the current category.
  ///
  /// Uses the appropriate dialog based on category:
  /// - Actions: [ActionDialog]
  /// - Flows: [FlowDialog]
  /// - Moments: [MomentDialog]
  /// - Thoughts: [ThoughtDialog]
  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (_) {
        onAdd(Task task) async {
          setState(() {
            _tasks.add(task);
            _lastEditedTaskId = task.id;
          });
          await TaskService.updateTasks(widget.category, _tasks);
        }

        switch (widget.category) {
          case Keys.actions:
            return ActionDialog(onAdd: onAdd, defaultList: _selectedFilter);
          case Keys.flows:
            return FlowDialog(onAdd: onAdd, defaultList: _selectedFilter);
          case Keys.moments:
            return MomentDialog(onAdd: onAdd, defaultList: _selectedFilter);
          case Keys.thoughts:
            return ThoughtDialog(onAdd: onAdd, defaultList: _selectedFilter);
          default:
            return const SizedBox.shrink();
        }
      },
    );
  }

  /// Shows a dialog for adding a new list/filter.
  ///
  /// Validates the new list name and updates the filters in the cloud.
  void _openAddTagDialog() {
    String newTag = '';
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Add List'),
            content: TextField(
              decoration: const InputDecoration(
                labelText: 'Enter new list name',
                hintText: 'E.g. Work, Home, etc.',
                border: OutlineInputBorder(),
              ),
              onChanged: (val) => newTag = val.trim(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Icon(ThemeIcons.cancel),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (newTag.isNotEmpty && !_filters.contains(newTag)) {
                    setState(() {
                      _filters.add(newTag);
                    });
                    await FilterService.updateFilters(
                      widget.category,
                      _filters,
                    );
                  }
                  if (!mounted) return;
                  Navigator.pop(context);
                },
                child: const Icon(ThemeIcons.done),
              ),
            ],
          ),
    );
  }

  /// Shows the edit task dialog for the current category.
  ///
  /// Uses the appropriate dialog based on category:
  /// - Actions: [ActionDialog]
  /// - Flows: [FlowDialog]
  /// - Moments: [MomentDialog]
  /// - Thoughts: [ThoughtDialog]
  ///
  /// [task] is the task to edit.
  void _showEditDialog(Task task) {
    showDialog(
      context: context,
      builder: (_) {
        onEdit(Task updatedTask) async {
          setState(() {
            final index = _tasks.indexWhere((t) => t.id == task.id);
            if (index != -1) {
              _tasks[index] = updatedTask;
              _lastEditedTaskId = task.id;
            }
          });
          await TaskService.updateTasks(widget.category, _tasks);
        }

        switch (widget.category) {
          case Keys.actions:
            return ActionDialog(
              onAdd: onEdit,
              defaultList: task.list,
              initialTask: task,
            );
          case Keys.flows:
            return FlowDialog(
              onAdd: onEdit,
              defaultList: task.list,
              initialTask: task,
            );
          case Keys.moments:
            return MomentDialog(
              onAdd: onEdit,
              defaultList: task.list,
              initialTask: task,
            );
          case Keys.thoughts:
            return ThoughtDialog(
              onAdd: onEdit,
              defaultList: task.list,
              initialTask: task,
            );
          default:
            return const SizedBox.shrink();
        }
      },
    );
  }

  /// Gets the empty state icon based on the category.
  ///
  /// Returns the appropriate icon for each category:
  /// - Actions: [ThemeIcons.actions]
  /// - Flows: [ThemeIcons.flows]
  /// - Moments: [ThemeIcons.moments]
  /// - Thoughts: [ThemeIcons.thoughts]
  /// - Default: [ThemeIcons.tasks]
  IconData _getEmptyStateIcon() {
    switch (widget.category) {
      case Keys.actions:
        return ThemeIcons.actions;
      case Keys.flows:
        return ThemeIcons.flows;
      case Keys.moments:
        return ThemeIcons.moments;
      case Keys.thoughts:
        return ThemeIcons.thoughts;
      default:
        return ThemeIcons.tasks;
    }
  }

  /// Gets the empty state title based on the category.
  ///
  /// Returns a category-specific title:
  /// - Actions: "No Actions Yet"
  /// - Flows: "No Flows Yet"
  /// - Moments: "No Moments Yet"
  /// - Thoughts: "No Thoughts Yet"
  /// - Default: "No Tasks Yet"
  String _getEmptyStateTitle() {
    switch (widget.category) {
      case Keys.actions:
        return 'No Actions Yet';
      case Keys.flows:
        return 'No Flows Yet';
      case Keys.moments:
        return 'No Moments Yet';
      case Keys.thoughts:
        return 'No Thoughts Yet';
      default:
        return 'No Tasks Yet';
    }
  }

  /// Gets the empty state message based on the category.
  ///
  /// Returns a category-specific message:
  /// - Actions: Message about adding tasks to to-do list
  /// - Flows: Message about creating routines and habits
  /// - Moments: Message about scheduling events and deadlines
  /// - Thoughts: Message about capturing ideas and reflections
  /// - Default: Generic message about adding items
  String _getEmptyStateMessage() {
    switch (widget.category) {
      case Keys.actions:
        return 'Start adding tasks to your to-do list\nand track your progress!';
      case Keys.flows:
        return 'Create your first routine to build\npositive habits and stay focused!';
      case Keys.moments:
        return 'Schedule your first event or deadline\nto stay organized and on track!';
      case Keys.thoughts:
        return 'Capture your first idea or reflection\nto keep track of your insights!';
      default:
        return 'Start by adding your first item\nto get started!';
    }
  }
}
