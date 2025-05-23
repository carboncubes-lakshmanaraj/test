import 'package:flutter/material.dart';
import 'package:subha_medicals/screens/tax_codes/view_tax_code_filter.dart';
// import 'tax_code_list_with_filter_screen.dart'; // Import your enums

class TaxCodeFilterDropdown extends StatelessWidget {
  final TaxCodeFilter selectedFilter;
  final void Function(TaxCodeFilter?) onFilterChanged;
  final String Function(TaxCodeFilter) getFilterText;

  const TaxCodeFilterDropdown({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.getFilterText,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<TaxCodeFilter>(
      onSelected: onFilterChanged,
      itemBuilder:
          (context) =>
              TaxCodeFilter.values.map((filter) {
                return PopupMenuItem<TaxCodeFilter>(
                  value: filter,
                  child: Row(
                    children: [
                      Radio<TaxCodeFilter>(
                        value: filter,
                        groupValue: selectedFilter,
                        onChanged: (value) {
                          Navigator.pop(context); // Close popup
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
