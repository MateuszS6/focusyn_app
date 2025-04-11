import 'package:flutter/material.dart';
import 'package:focusyn_app/data/app_data.dart';

class FilterRow extends StatelessWidget {
  final String category;
  final List<String> filters;
  final Set<String> hidden;
  final String selected;
  final void Function(String) onSelect;
  final VoidCallback onAdd;

  const FilterRow({
    super.key,
    required this.category,
    required this.filters,
    required this.hidden,
    required this.selected,
    required this.onSelect,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final visibleFilters = filters.where((f) => !hidden.contains(f)).toList();

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: visibleFilters.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (index < visibleFilters.length) {
            final tag = visibleFilters[index];
            final isSelected = tag == selected;
            return ActionChip(
              label: Text(tag),
              shape: const StadiumBorder(),
              onPressed: () => onSelect(tag),
              backgroundColor:
                  isSelected
                      ? AppData.instance.colours[category]!['main']!
                      : Colors.grey[200],
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontSize: 13,
              ),
            );
          } else {
            return ActionChip(
              label: const Icon(Icons.add, size: 18),
              shape: const StadiumBorder(),
              onPressed: onAdd,
              backgroundColor: Colors.grey[200],
            );
          }
        },
      ),
    );
  }
}
