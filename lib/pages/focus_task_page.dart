import 'dart:math';

import 'package:flutter/material.dart';
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
import 'package:focusyn_app/util/my_app_bar.dart';
import 'package:focusyn_app/util/tag_manager_dialog.dart';

class FocusTaskPage extends StatefulWidget {
  final String category;
  const FocusTaskPage({super.key, required this.category});

  @override
  State<FocusTaskPage> createState() => _FocusTaskPageState();
}

class _FocusTaskPageState extends State<FocusTaskPage> {
  late List<Map<String, dynamic>> _tasks;
  late List<String> _filters;
  late Set<String> _hidden;

  String _selectedFilter = Keys.all;

  List<Map<String, dynamic>> get _filteredTasks =>
      _selectedFilter == Keys.all
          ? _tasks
          : _tasks.where((task) => task[Keys.tag] == _selectedFilter).toList();

  @override
  void initState() {
    super.initState();
    _tasks = AppData.instance.tasks[widget.category]!;
    _filters = AppData.instance.filters[widget.category]!;
    _hidden = AppData.instance.hiddenFilters[widget.category]!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: widget.category,
        actions: [
          PopupMenuButton<String>(
            itemBuilder:
                (_) => const [
                  PopupMenuItem(value: 'tags', child: Text("Manage Tags")),
                  PopupMenuItem(value: 'tasks', child: Text("Sort Tasks")),
                ],
            onSelected: _handleMenuSelection,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            FilterRow(
              category: widget.category,
              filters: _filters,
              hidden: _hidden,
              selected: _selectedFilter,
              onSelect: (val) => setState(() => _selectedFilter = val),
              onAdd: _openAddTagDialog,
            ),
            const SizedBox(height: 16),
            Expanded(
              child:
                  _filteredTasks.isEmpty
                      ? const Center(child: Text("No tasks to show."))
                      : _buildReorderableList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        foregroundColor: Colors.white,
        backgroundColor: AppData.instance.colours[widget.category]?['main'],
        onPressed: _showAddDialog,
        child: const Icon(Icons.add_rounded, size: 40),
      ),
    );
  }

  Widget _buildReorderableList() {
    return ReorderableListView.builder(
      itemCount: _filteredTasks.length,
      onReorder: (oldIndex, newIndex) {
        if (newIndex > oldIndex) newIndex--;
        final visible = _filteredTasks;
        final dragged = visible.removeAt(oldIndex);
        visible.insert(newIndex, dragged);

        setState(() {
          _tasks
            ..remove(dragged)
            ..insert(
              _tasks.indexOf(visible[min(newIndex, _tasks.length - 1)]),
              dragged,
            );
          AppData.instance.updateTasks(widget.category, _tasks);
        });
      },
      itemBuilder: (_, index) {
        final task = _filteredTasks[index];
        final color = AppData.instance.colours[widget.category]!['task']!;

        switch (widget.category) {
          case Keys.actions:
            return ActionTile(
              key: ValueKey(task),
              color: color,
              task: task,
              onEdit: (newTitle) {
                setState(() => task[Keys.title] = newTitle);
                AppData.instance.updateTasks(widget.category, _tasks);
              },
              onComplete: () {
                setState(() => _tasks.remove(task));
                AppData.instance.updateTasks(widget.category, _tasks);
              },
              onDelete: () {
                setState(() => _tasks.remove(task));
                AppData.instance.updateTasks(widget.category, _tasks);
              },
            );
          case Keys.flows:
            return FlowTile(
              key: ValueKey(task),
              color: color,
              task: task,
              onEdit: (newTitle) {
                setState(() => task[Keys.title] = newTitle);
                AppData.instance.updateTasks(widget.category, _tasks);
              },
              onComplete: () {
                AppData.instance.updateTasks(widget.category, _tasks);
              },
              onDelete: () {
                setState(() => _tasks.remove(task));
                AppData.instance.updateTasks(widget.category, _tasks);
              },
            );
          case Keys.moments:
            return MomentTile(
              key: ValueKey(task),
              color: color,
              task: task,
              onEdit: (newTitle) {
                setState(() => task[Keys.title] = newTitle);
                AppData.instance.updateTasks(widget.category, _tasks);
              },
              onDelete: () {
                setState(() => _tasks.remove(task));
                AppData.instance.updateTasks(widget.category, _tasks);
              },
            );
          case Keys.thoughts:
            return ThoughtTile(
              key: ValueKey(task),
              color: color,
              task: task,
              onEdit: (newText) {
                setState(() => task[Keys.text] = newText);
                AppData.instance.updateTasks(widget.category, _tasks);
              },
              onDelete: () {
                setState(() => _tasks.remove(task));
                AppData.instance.updateTasks(widget.category, _tasks);
              },
            );
          default:
            return const SizedBox.shrink();
        }
      },
    );
  }

  void _handleMenuSelection(String val) {
    if (val == 'tags') {
      _openTagManagerDialog();
    } else if (val == 'tasks') {
      // TODO: Implement task sorting
    }
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (_) {
        onAdd(TaskModel task) {
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
}
