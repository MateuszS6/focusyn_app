// focus_task_page.dart
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:focusyn_app/app_data.dart';
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

class FocusTaskPage extends StatefulWidget {
  final String category;

  const FocusTaskPage({super.key, required this.category});

  @override
  State<FocusTaskPage> createState() => _FocusTaskPageState();
}

class _FocusTaskPageState extends State<FocusTaskPage> {
  List<Map<String, dynamic>> get _tasks =>
      AppData.instance.tasks[widget.category]!;
  List<String> get _filters => AppData.instance.filters[widget.category]!;
  Set<String> get _hidden => AppData.instance.hiddenFilters[widget.category]!;

  String _selectedFilter = 'All';
  List<Map<String, dynamic>> get _filteredTasks {
    if (_selectedFilter == 'All') return _tasks;
    return _tasks.where((task) => task['tag'] == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.category),
        actions: [
          PopupMenuButton<String>(
            itemBuilder:
                (context) => [
                  PopupMenuItem(value: 'tags', child: Text("Manage Tags")),
                  PopupMenuItem(value: 'tasks', child: Text("Sort Tasks")),
                ],
            onSelected: (val) {
              if (val == 'tags') {
                _openTagManagerDialog();
              } else if (val == 'tasks') {
                // TODO: Implement task sort
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

                          if (widget.category == 'Actions') {
                            return ActionTile(
                              key: ValueKey(task),
                              task: task,
                              onComplete:
                                  () => setState(() => _tasks.remove(task)),
                              onEdit:
                                  (newTitle) =>
                                      setState(() => task["title"] = newTitle),
                            );
                          } else if (widget.category == 'Flows') {
                            return FlowTile(
                              key: ValueKey(task),
                              task: task,
                              onEdit:
                                  (newTitle) =>
                                      setState(() => task["title"] = newTitle),
                              // Add any other Flow-specific callbacks here
                            );
                          } else if (widget.category == 'Moments') {
                            return MomentTile(
                              key: ValueKey(task),
                              task: task,
                              onEdit:
                                  (newTitle) =>
                                      setState(() => task["title"] = newTitle),
                              // Add any other Moment-specific callbacks here
                            );
                          } else if (widget.category == 'Thoughts') {
                            return ThoughtTile(
                              key: ValueKey(task),
                              task: task,
                              onEdit:
                                  (newText) =>
                                      setState(() => task["text"] = newText),
                            );
                          } else {
                            return SizedBox.shrink(); // Fallback
                          }
                        },
                      ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) {
              if (widget.category == 'Actions') {
                return AddActionDialog(
                  onAdd: (task) => setState(() => _tasks.add(task)),
                );
              } else if (widget.category == 'Flows') {
                return AddFlowDialog(
                  onAdd: (task) => setState(() => _tasks.add(task)),
                );
              } else if (widget.category == 'Moments') {
                return AddMomentDialog(
                  onAdd: (task) => setState(() => _tasks.add(task)),
                );
              } else if (widget.category == 'Thoughts') {
                return AddThoughtDialog(
                  onAdd: (task) => setState(() => _tasks.add(task)),
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          );
        },
        foregroundColor: Colors.white,
        backgroundColor: Colors.blue[400],
        child: Icon(Icons.add_rounded, size: 40),
      ),
    );
  }

  /// Opens a dialog to add a new tag.
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
                      _filters.add(newTag);
                      _hidden.remove(newTag);
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

  /// Opens the tag manager dialog to manage tags.
  void _openTagManagerDialog() {
    showDialog(
      context: context,
      builder:
          (_) => TagManagerDialog(
            tags: _filters,
            onRename: (oldTag, newTag) {
              setState(() {
                for (var task in _tasks) {
                  if (task['tag'] == oldTag) task['tag'] = newTag;
                }
                final index = _filters.indexOf(oldTag);
                if (index != -1) _filters[index] = newTag;

                if (_hidden.remove(oldTag)) _hidden.add(newTag);

                if (_selectedFilter == oldTag) _selectedFilter = newTag;
              });
            },
            onDelete: (tag) {
              setState(() {
                _filters.remove(tag);
                _hidden.remove(tag);
                _tasks.removeWhere((task) => task['tag'] == tag);
                if (_selectedFilter == tag) _selectedFilter = 'All';
              });
            },
            onToggleHide: (tag) {
              setState(() {
                if (_hidden.contains(tag)) {
                  _hidden.remove(tag);
                } else {
                  _hidden.add(tag);
                  if (_selectedFilter == tag) _selectedFilter = 'All';
                }
              });
            },
            onReorder: (newOrder) {
              setState(() {
                AppData.instance.filters[widget.category] = List<String>.from(
                  newOrder,
                );
              });
            },
          ),
    );
  }
}
