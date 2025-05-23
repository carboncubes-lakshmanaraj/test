import 'package:flutter/material.dart';
import 'package:subha_medicals/screens/tax_codes/view_tax_code_filter.dart';
// import 'tax_code_list_with_filter_screen.dart'; // For ActiveFilter enum

class ActiveFilterDropdown extends StatelessWidget {
  final ActiveFilter selectedFilter;
  final void Function(ActiveFilter?) onFilterChanged;
  final String Function(ActiveFilter) getFilterText;

  const ActiveFilterDropdown({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.getFilterText,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<ActiveFilter>(
      onSelected: onFilterChanged,
      itemBuilder:
          (context) =>
              ActiveFilter.values.map((filter) {
                return PopupMenuItem<ActiveFilter>(
                  value: filter,
                  child: Row(
                    children: [
                      Radio<ActiveFilter>(
                        value: filter,
                        groupValue: selectedFilter,
                        onChanged: (value) {
                          Navigator.pop(context); // Close the popup
                          onFilterChanged(value);
                        },
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(getFilterText(filter))),
                    ],
                  ),
                );
              }).toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                getFilterText(selectedFilter),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }
}
