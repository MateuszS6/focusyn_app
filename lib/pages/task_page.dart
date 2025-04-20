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

class TaskPage extends StatefulWidget {
  final String category;
  const TaskPage({super.key, required this.category});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  late List<Map<String, dynamic>> _tasks;
  late List<String> _filters;
  String _selectedFilter = Keys.all;
  String _sortBy = 'Date';

  List<Map<String, dynamic>> get _filteredTasks {
    var filtered =
        _selectedFilter == Keys.all
            ? _tasks
            : _tasks
                .where((task) => task[Keys.list] == _selectedFilter)
                .toList();

    // Sort tasks
    filtered.sort((a, b) {
      switch (_sortBy) {
        case 'Priority':
          final priorityCompare = (a['priority'] ?? 1).compareTo(
            b['priority'] ?? 1,
          );
          if (priorityCompare != 0) return priorityCompare;
          break;
        case 'Brain Points':
          final bpCompare = (a['brainPoints'] ?? 0).compareTo(
            b['brainPoints'] ?? 0,
          );
          if (bpCompare != 0) return bpCompare;
          break;
        case 'Alphabetical':
          final titleCompare = (a['title'] ?? '').compareTo(b['title'] ?? '');
          if (titleCompare != 0) return titleCompare;
          break;
        case 'Date':
          if (widget.category == Keys.flows ||
              widget.category == Keys.moments) {
            final dateCompare = (a['date'] ?? '').compareTo(b['date'] ?? '');
            if (dateCompare != 0) return dateCompare;
          }
          break;
      }
      // Default to creation date
      final aDate = DateTime.parse(a[Keys.createdAt] as String);
      final bDate = DateTime.parse(b[Keys.createdAt] as String);
      return aDate.compareTo(bDate);
    });

    return filtered;
  }

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
                    _tasks.removeWhere((task) => task[Keys.list] == tag);
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

  void _showSortDialog() {
    List<RadioListTile> options = [];

    switch (widget.category) {
      case Keys.actions:
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

  Widget _buildEmptyState() {
    final color = switch (widget.category) {
      Keys.actions => ThemeColours.actionsMain,
      Keys.flows => ThemeColours.flowsMain,
      Keys.moments => ThemeColours.momentsMain,
      Keys.thoughts => ThemeColours.thoughtsMain,
      _ => ThemeColours.taskMain,
    };
    return Center(
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
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _getEmptyStateMessage(),
            style: const TextStyle(fontSize: 16, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _showAddDialog,
            icon: const Icon(ThemeIcons.add, color: Colors.white),
            label: Text(
              "Add ${widget.category.substring(0, widget.category.length - 1)}",
              style: const TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList() {
    return MyScrollShadow(
      child: ListView.separated(
        itemCount: _filteredTasks.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        padding: const EdgeInsets.symmetric(vertical: 4),
        itemBuilder: (_, index) => _buildTaskTile(_filteredTasks[index]),
      ),
    );
  }

  Widget _buildTaskTile(Map<String, dynamic> task) {
    final key = ValueKey(task);

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
          task: Task.fromMap(task),
          onEdit: () => _showEditDialog(task),
          onComplete: () => _removeTask(task),
          onDelete: () => _removeTask(task),
          selectedFilter: _selectedFilter,
        );
        break;

      case Keys.flows:
        tile = FlowTile(
          key: key,
          task: Task.fromMap(task),
          onComplete: (updatedTask) {
            setState(() => _tasks[_tasks.indexOf(task)] = updatedTask.toMap());
            _updateTask(task);
          },
          onDelete: () => _removeTask(task),
          selectedFilter: _selectedFilter,
          onEdit: () => _showEditDialog(task),
        );
        break;

      case Keys.moments:
        tile = MomentTile(
          key: key,
          task: Task.fromMap(task),
          onDelete: () => _removeTask(task),
          selectedFilter: _selectedFilter,
          onEdit: () => _showEditDialog(task),
        );
        break;

      case Keys.thoughts:
        tile = ThoughtTile(
          key: key,
          task: Task.fromMap(task),
          onDelete: () => _removeTask(task),
          selectedFilter: _selectedFilter,
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
      child: tile,
    );
  }

  // Task Operations
  Future<void> _updateTask(Map<String, dynamic> task) async {
    setState(() {});
    await TaskService.updateTasks(widget.category, _tasks);
  }

  Future<void> _removeTask(Map<String, dynamic> task) async {
    setState(() => _tasks.remove(task));
    await TaskService.updateTasks(widget.category, _tasks);
  }

  // Dialog Operations
  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (_) {
        onAdd(Task task) async {
          setState(() => _tasks.add(task.toMap()));
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

  void _openAddTagDialog() {
    String newTag = "";
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Add List"),
            content: TextField(
              decoration: const InputDecoration(
                labelText: "Enter new list name",
                hintText: "E.g. Work, Home, etc.",
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

  void _showEditDialog(Map<String, dynamic> task) {
    showDialog(
      context: context,
      builder: (_) {
        onEdit(Task updatedTask) async {
          setState(() => _tasks[_tasks.indexOf(task)] = updatedTask.toMap());
          await TaskService.updateTasks(widget.category, _tasks);
        }

        switch (widget.category) {
          case Keys.actions:
            return ActionDialog(
              onAdd: onEdit,
              defaultList: task[Keys.list],
              initialTask: Task.fromMap(task),
            );
          case Keys.flows:
            return FlowDialog(
              onAdd: onEdit,
              defaultList: task[Keys.list],
              initialTask: Task.fromMap(task),
            );
          case Keys.moments:
            return MomentDialog(
              onAdd: onEdit,
              defaultList: task[Keys.list],
              initialTask: Task.fromMap(task),
            );
          case Keys.thoughts:
            return ThoughtDialog(
              onAdd: onEdit,
              defaultList: task[Keys.list],
              initialTask: Task.fromMap(task),
            );
          default:
            return const SizedBox.shrink();
        }
      },
    );
  }

  // Empty State Helpers
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

  String _getEmptyStateTitle() {
    switch (widget.category) {
      case Keys.actions:
        return "No Actions Yet";
      case Keys.flows:
        return "No Flows Yet";
      case Keys.moments:
        return "No Moments Yet";
      case Keys.thoughts:
        return "No Thoughts Yet";
      default:
        return "No Tasks Yet";
    }
  }

  String _getEmptyStateMessage() {
    switch (widget.category) {
      case Keys.actions:
        return "Start adding tasks to your to-do list\nand track your progress!";
      case Keys.flows:
        return "Create your first routine to build\npositive habits and stay focused!";
      case Keys.moments:
        return "Schedule your first event or deadline\nto stay organized and on track!";
      case Keys.thoughts:
        return "Capture your first idea or reflection\nto keep track of your insights!";
      default:
        return "Start by adding your first item\nto get started!";
    }
  }
}
