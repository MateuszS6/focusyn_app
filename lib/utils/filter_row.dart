import 'package:flutter/material.dart';
import 'package:focusyn_app/constants/theme_colours.dart';
import 'package:focusyn_app/constants/keys.dart';
import 'package:focusyn_app/constants/theme_icons.dart';
import 'package:focusyn_app/utils/my_scroll_shadow.dart';

class FilterRow extends StatelessWidget {
  final String category;
  final List<String> filters;
  final String selected;
  final void Function(String) onSelect;
  final VoidCallback onAdd;
  final Future<void> Function(String) onDelete;

  const FilterRow({
    super.key,
    required this.category,
    required this.filters,
    required this.selected,
    required this.onSelect,
    required this.onAdd,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final color = switch (category) {
      Keys.actions => ThemeColours.actionsMain,
      Keys.flows => ThemeColours.flowsMain,
      Keys.moments => ThemeColours.momentsMain,
      Keys.thoughts => ThemeColours.thoughtsMain,
      _ => ThemeColours.taskMain,
    };

    return SizedBox(
      height: 32,
      child: MyScrollShadow(
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: filters.length + 1,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (context, index) {
            if (index < filters.length) {
              final list = filters[index];
              final isSelected = list == selected;
              return GestureDetector(
                onLongPress: () {
                  if (list != Keys.all) {
                    showDialog(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            title: Text('Delete "$list"?'),
                            content: const Text(
                              'This will remove the list and all its tasks.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Icon(ThemeIcons.cancel),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  Navigator.pop(context);
                                  await onDelete(list);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                    );
                  }
                },
                child: ActionChip(
                  label: Text(
                    list,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontSize: 14,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  shape: const StadiumBorder(),
                  onPressed: () => onSelect(list),
                  backgroundColor: isSelected ? color : Colors.grey[200],
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  side: BorderSide.none,
                ),
              );
            } else {
              return ActionChip(
                label: Icon(ThemeIcons.add, size: 20, color: color),
                shape: const StadiumBorder(),
                onPressed: onAdd,
                backgroundColor: Colors.grey[200],
                padding: const EdgeInsets.symmetric(horizontal: 16),
                side: BorderSide.none,
              );
            }
          },
        ),
      ),
    );
  }
}
