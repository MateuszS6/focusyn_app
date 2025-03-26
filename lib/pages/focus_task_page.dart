// focus_task_page.dart
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:focusyn_app/elements/add_task_dialog.dart';
import 'package:focusyn_app/elements/filter_row.dart';
import 'package:focusyn_app/elements/tag_manager_dialog.dart';
import 'package:focusyn_app/elements/task_tile.dart';

class FocusTaskPage extends StatefulWidget {
  final String category;
  final List<Map<String, dynamic>> taskList;

  const FocusTaskPage({
    super.key,
    required this.category,
    required this.taskList,
  });

  @override
  State<FocusTaskPage> createState() => _FocusTaskPageState();
}

class _FocusTaskPageState extends State<FocusTaskPage> {
  late List<Map<String, dynamic>> _tasks;
  late Map<String, List<String>> _filtersPerCategory;
  late Map<String, Set<String>> _hiddenPerCategory;

  List<String> get _filters => _filtersPerCategory[widget.category] ?? ['All'];
  Set<String> get _hidden => _hiddenPerCategory[widget.category] ?? {};

  String _selectedFilter = 'All';

  List<Map<String, dynamic>> get _filteredTasks {
    if (_selectedFilter == 'All') return _tasks;
    return _tasks.where((task) => task['tag'] == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.category),
        actions: [
          PopupMenuButton<String>(
            itemBuilder:
                (context) => [
                  PopupMenuItem(value: 'tags', child: Text("Manage Tags")),
                  PopupMenuItem(value: 'tasks', child: Text("Manage Tasks")),
                ],
            onSelected: (val) {
              if (val == 'tags') {
                _openTagManagerDialog();
              } else if (val == 'tasks') {
                // TODO: Implement task manager dialog
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            FilterRow(
              filters: _filters,
              hidden: _hidden,
              selected: _selectedFilter,
              onSelect: (val) => setState(() => _selectedFilter = val),
              onAdd: _openAddTagDialog,
            ),
            SizedBox(height: 16),
            Expanded(
              child:
                  _filteredTasks.isEmpty
                      ? Center(child: Text("No tasks to show."))
                      : ReorderableListView.builder(
                        itemCount: _filteredTasks.length,
                        onReorder: (oldIndex, newIndex) {
                          if (newIndex > oldIndex) newIndex--;

                          final visible = _filteredTasks;
                          final dragged = visible.removeAt(oldIndex);
                          visible.insert(newIndex, dragged);

                          setState(() {
                            // Reflect the change in _tasks (master list)
                            _tasks
                              ..removeWhere((t) => t == dragged)
                              ..insert(
                                _tasks.indexOf(
                                  visible[min(newIndex, _tasks.length - 1)],
                                ),
                                dragged,
                              );
                          });
                        },
                        itemBuilder: (context, index) {
                          final task = _filteredTasks[index];
                          return TaskTile(
                            key: ValueKey(task),
                            task: task,
                            onComplete: () {
                              setState(() {
                                _tasks.remove(task);
                              });
                            },
                            onEdit: (newTitle) {
                              setState(() {
                                task["title"] = newTitle;
                              });
                            },
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:
            () => showDialog(
              context: context,
              builder:
                  (_) => AddTaskDialog(
                    filters: _filters,
                    onAdd: (task) => setState(() => _tasks.add(task)),
                  ),
            ),
        foregroundColor: Colors.white,
        backgroundColor: Colors.blue[400],
        child: Icon(Icons.add_rounded, size: 30),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _tasks = List<Map<String, dynamic>>.from(widget.taskList);
    _filtersPerCategory = {
      'Actions': ['All', 'Home', 'Errands', 'Study'],
      'Flows': ['All', 'Morning', 'Evening', 'Wellness'],
      'Moments': ['All', 'Events', 'Appointments'],
      'Thoughts': ['All', 'Ideas', 'Journal'],
    };
    _hiddenPerCategory = {
      'Actions': {},
      'Flows': {},
      'Moments': {},
      'Thoughts': {},
    };
  }

  void _openAddTagDialog() {
    String newTag = "";
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text("Add List"),
            content: TextField(
              decoration: InputDecoration(hintText: "Enter new list name"),
              onChanged: (val) => newTag = val.trim(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () {
                  if (newTag.isNotEmpty && !_filters.contains(newTag)) {
                    setState(() {
                      _filtersPerCategory[widget.category]!.add(newTag);
                      _hiddenPerCategory[widget.category]!.remove(newTag);
                      // _selectedFilter = newTag;
                    });
                  }
                  Navigator.pop(context);
                },
                child: Text("Add"),
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
            tags: _filtersPerCategory[widget.category]!,
            onRename: (oldTag, newTag) {
              setState(() {
                for (var task in _tasks) {
                  if (task['tag'] == oldTag) task['tag'] = newTag;
                }
                final list = _filtersPerCategory[widget.category]!;
                final index = list.indexOf(oldTag);
                if (index != -1) list[index] = newTag;

                final hidden = _hiddenPerCategory[widget.category]!;
                if (hidden.remove(oldTag)) hidden.add(newTag);

                if (_selectedFilter == oldTag) _selectedFilter = newTag;
              });
            },
            onDelete: (tag) {
              setState(() {
                _filtersPerCategory[widget.category]!.remove(tag);
                _hiddenPerCategory[widget.category]!.remove(tag);
                _tasks.removeWhere((task) => task['tag'] == tag);
                if (_selectedFilter == tag) _selectedFilter = 'All';
              });
            },
            onToggleHide: (tag) {
              setState(() {
                final hidden = _hiddenPerCategory[widget.category]!;
                if (hidden.contains(tag)) {
                  hidden.remove(tag);
                } else {
                  hidden.add(tag);
                  if (_selectedFilter == tag) _selectedFilter = 'All';
                }
              });
            },
            onReorder: (newOrder) {
              setState(() {
                _filtersPerCategory[widget.category] = List<String>.from(
                  newOrder,
                );
              });
            },
          ),
    );
  }
}
