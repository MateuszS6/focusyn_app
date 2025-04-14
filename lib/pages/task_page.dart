import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:focusyn_app/data/app_data.dart';
import 'package:focusyn_app/data/keys.dart';
import 'package:focusyn_app/models/task_model.dart';
import 'package:focusyn_app/task_dialogs/add_action_dialog.dart';
import 'package:focusyn_app/task_dialogs/add_flow_dialog.dart';
import 'package:focusyn_app/task_dialogs/add_moment_dialog.dart';
import 'package:focusyn_app/task_dialogs/add_thought_dialog.dart';
import 'package:focusyn_app/task_tiles/action_tile.dart';
import 'package:focusyn_app/task_tiles/flow_tile.dart';
import 'package:focusyn_app/task_tiles/moment_tile.dart';
import 'package:focusyn_app/task_tiles/thought_tile.dart';
import 'package:focusyn_app/util/filter_row.dart';
import 'package:focusyn_app/util/tag_manager_dialog.dart';

class TaskPage extends StatefulWidget {
  final String category;
  const TaskPage({super.key, required this.category});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  late List<Map<String, dynamic>> _tasks;
  late List<String> _filters;
  late Set<String> _hidden;
  String _selectedFilter = Keys.all;
  String _sortBy = 'Date';

  List<Map<String, dynamic>> get _filteredTasks {
    var filtered =
        _selectedFilter == Keys.all
            ? _tasks
            : _tasks
                .where((task) => task[Keys.tag] == _selectedFilter)
                .toList();

    // Sort tasks
    filtered.sort((a, b) {
      if (_sortBy == 'Priority') {
        final priorityCompare = (a['priority'] ?? 1).compareTo(
          b['priority'] ?? 1,
        );
        if (priorityCompare != 0) return priorityCompare;
      }
      final aDate = DateTime.parse(a[Keys.createdAt] as String);
      final bDate = DateTime.parse(b[Keys.createdAt] as String);
      return aDate.compareTo(bDate);
    });

    return filtered;
  }

  @override
  void initState() {
    super.initState();
    _tasks = AppData.instance.tasks[widget.category]!;
    _filters = AppData.instance.filters[widget.category]!;
    _hidden = AppData.instance.hiddenFilters[widget.category]!;
  }

  @override
  Widget build(BuildContext context) {
    final color = AppData.instance.colours[widget.category]!['main']!;

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
                    icon: const Icon(Icons.arrow_back_ios_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.category,
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.sort_rounded),
                    onPressed: _showSortDialog,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              FilterRow(
                category: widget.category,
                filters: _filters,
                hidden: _hidden,
                selected: _selectedFilter,
                onSelect: (filter) => setState(() => _selectedFilter = filter),
                onAdd: _openAddTagDialog,
                onDelete: (tag) {
                  setState(() {
                    _filters.remove(tag);
                    _hidden.remove(tag);
                    _tasks.removeWhere((task) => task[Keys.tag] == tag);
                    if (_selectedFilter == tag) _selectedFilter = Keys.all;
                    AppData.instance.updateTasks(widget.category, _tasks);
                    AppData.instance.updateFilters(widget.category, _filters);
                    AppData.instance.updateHidden(widget.category, _hidden);
                  });
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
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: color,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add_rounded, size: 32),
      ),
    );
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Sort Tasks'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                  title: const Text('Priority'),
                  value: 'Priority',
                  groupValue: _sortBy,
                  onChanged: (value) {
                    setState(() => _sortBy = value.toString());
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildEmptyState() {
    final color = AppData.instance.colours[widget.category]!['main']!;
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
            icon: const Icon(Icons.add_rounded, color: Colors.white),
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
    return ListView.separated(
      itemCount: _filteredTasks.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemBuilder: (_, index) => _buildTaskTile(_filteredTasks[index]),
    );
  }

  Widget _buildTaskTile(Map<String, dynamic> task) {
    final color = AppData.instance.colours[widget.category]!['task']!;
    final key = ValueKey(task);

    Widget tile;
    List<SlidableAction> actions = [
      SlidableAction(
        onPressed: (_) => _removeTask(task),
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFFE53935),
        icon: Icons.do_not_disturb_on_rounded,
        padding: EdgeInsets.zero,
      ),
    ];

    switch (widget.category) {
      case Keys.actions:
        tile = ActionTile(
          key: key,
          color: color,
          task: Task.fromMap(task),
          onEdit: () => _updateTask(task),
          onComplete: () => _removeTask(task),
          onDelete: () => _removeTask(task),
        );
        break;

      case Keys.flows:
        tile = FlowTile(
          key: key,
          color: color,
          task: task,
          onEdit: (newTitle) {
            task[Keys.title] = newTitle;
            _updateTask(task);
          },
          onComplete: () => _updateTask(task),
          onDelete: () => _removeTask(task),
        );
        break;

      case Keys.moments:
        tile = MomentTile(
          key: key,
          color: color,
          task: task,
          onEdit: (newTitle) {
            task[Keys.title] = newTitle;
            _updateTask(task);
          },
          onDelete: () => _removeTask(task),
        );
        break;

      case Keys.thoughts:
        tile = ThoughtTile(
          key: key,
          color: color,
          task: task,
          onEdit: (newText) {
            task[Keys.text] = newText;
            _updateTask(task);
          },
          onDelete: () => _removeTask(task),
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
  void _updateTask(Map<String, dynamic> task) {
    setState(() {});
    AppData.instance.updateTasks(widget.category, _tasks);
  }

  void _removeTask(Map<String, dynamic> task) {
    setState(() => _tasks.remove(task));
    AppData.instance.updateTasks(widget.category, _tasks);
  }

  // Dialog Operations
  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (_) {
        onAdd(Task task) {
          setState(() => _tasks.add(task.toMap()));
          AppData.instance.updateTasks(widget.category, _tasks);
        }

        switch (widget.category) {
          case Keys.actions:
            return AddActionDialog(onAdd: onAdd);
          case Keys.flows:
            return AddFlowDialog(onAdd: onAdd);
          case Keys.moments:
            return AddMomentDialog(onAdd: onAdd);
          case Keys.thoughts:
            return AddThoughtDialog(onAdd: onAdd);
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
                hintText: "Enter new list name",
              ),
              onChanged: (val) => newTag = val.trim(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () {
                  if (newTag.isNotEmpty && !_filters.contains(newTag)) {
                    setState(() {
                      _filters.add(newTag);
                      _hidden.remove(newTag);
                      AppData.instance.updateFilters(widget.category, _filters);
                      AppData.instance.updateHidden(widget.category, _hidden);
                    });
                  }
                  Navigator.pop(context);
                },
                child: const Text("Add"),
              ),
            ],
          ),
    );
  }

  void _openTagManagerDialog() {
    showDialog(
      context: context,
      builder:
          (_) => TagManagerDialog(
            tags: _filters,
            onRename: (oldTag, newTag) {
              setState(() {
                for (var task in _tasks) {
                  if (task[Keys.tag] == oldTag) task[Keys.tag] = newTag;
                }
                final index = _filters.indexOf(oldTag);
                if (index != -1) _filters[index] = newTag;
                if (_hidden.remove(oldTag)) _hidden.add(newTag);
                if (_selectedFilter == oldTag) _selectedFilter = newTag;
                AppData.instance.updateTasks(widget.category, _tasks);
                AppData.instance.updateFilters(widget.category, _filters);
                AppData.instance.updateHidden(widget.category, _hidden);
              });
            },
            onDelete: (tag) {
              setState(() {
                _filters.remove(tag);
                _hidden.remove(tag);
                _tasks.removeWhere((task) => task[Keys.tag] == tag);
                if (_selectedFilter == tag) _selectedFilter = Keys.all;
                AppData.instance.updateTasks(widget.category, _tasks);
                AppData.instance.updateFilters(widget.category, _filters);
                AppData.instance.updateHidden(widget.category, _hidden);
              });
            },
            onToggleHide: (tag) {
              setState(() {
                _hidden.contains(tag) ? _hidden.remove(tag) : _hidden.add(tag);
                if (_selectedFilter == tag) _selectedFilter = Keys.all;
                AppData.instance.updateFilters(widget.category, _filters);
                AppData.instance.updateHidden(widget.category, _hidden);
              });
            },
            onReorder: (newOrder) {
              setState(() {
                AppData.instance.filters[widget.category] = List.from(newOrder);
                AppData.instance.updateFilters(widget.category, _filters);
                AppData.instance.updateHidden(widget.category, _hidden);
              });
            },
          ),
    );
  }

  // Empty State Helpers
  IconData _getEmptyStateIcon() {
    switch (widget.category) {
      case Keys.actions:
        return Icons.check_circle_rounded;
      case Keys.flows:
        return Icons.replay_circle_filled_rounded;
      case Keys.moments:
        return Icons.event_rounded;
      case Keys.thoughts:
        return Icons.lightbulb_rounded;
      default:
        return Icons.task_alt;
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
