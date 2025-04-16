import 'package:flutter/material.dart';
import 'package:focusyn_app/constants/theme_constants.dart';
import 'package:focusyn_app/constants/keys.dart';

class FilterRow extends StatelessWidget {
  final String category;
  final List<String> filters;
  final String selected;
  final void Function(String) onSelect;
  final VoidCallback onAdd;
  final void Function(String) onDelete;

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
    final color = ThemeConstants.focusColors[category]!['main']!;

    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          if (index < filters.length) {
            final tag = filters[index];
            final isSelected = tag == selected;
            return GestureDetector(
              onLongPress: () {
                if (tag != Keys.all) {
                  showDialog(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: Text('Delete "$tag"?'),
                          content: const Text(
                            'This will remove the list and all its tasks.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                onDelete(tag);
                                Navigator.pop(context);
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
                  tag,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontSize: 14,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                shape: const StadiumBorder(),
                onPressed: () => onSelect(tag),
                backgroundColor: isSelected ? color : Colors.grey[200],
                padding: const EdgeInsets.symmetric(horizontal: 16),
                side: BorderSide.none,
              ),
            );
          } else {
            return ActionChip(
              label: Icon(Icons.add_rounded, size: 20, color: color),
              shape: const StadiumBorder(),
              onPressed: onAdd,
              backgroundColor: Colors.grey[200],
              padding: const EdgeInsets.symmetric(horizontal: 16),
              side: BorderSide.none,
            );
          }
        },
      ),
    );
  }
}
