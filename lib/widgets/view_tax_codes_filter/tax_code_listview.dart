import 'package:flutter/material.dart';
import 'package:subha_medicals/models/tax_code/tax_code_class_model.dart';
// import 'your_tax_model_file.dart'; // Replace with the file where TaxCode model is defined

class TaxCodeListView extends StatelessWidget {
  final bool isLoading;
  final List<TaxCode> filteredTaxCodes;
  final TaxCode? selectedTaxCode;
  final void Function(TaxCode) onListItemTapped;
  final Future<TaxCode?> Function(BuildContext, TaxCode) onEdit;

  const TaxCodeListView({
    super.key,
    required this.isLoading,
    required this.filteredTaxCodes,
    required this.selectedTaxCode,
    required this.onListItemTapped,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (filteredTaxCodes.isEmpty) {
      return const Center(child: Text('No tax codes found'));
    }

    return ListView.builder(
      itemCount: filteredTaxCodes.length,
      itemBuilder: (context, index) {
        final tax = filteredTaxCodes[index];
        final isSelected = selectedTaxCode?.taxCode == tax.taxCode;

        return Card(
          child: ListTile(
            selected: isSelected,
            selectedTileColor: Colors.blue.shade100,
            title: Text('ID - ${tax.taxCode} - ${tax.description}'),
            subtitle: Text(
              'CESS: ${tax.cess} | CGST: ${tax.cgst} | SGST: ${tax.sgst} | IGST: ${tax.igst}',
            ),
            onTap: () => onListItemTapped(tax),
            trailing: IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () async {
                final updatedTax = await onEdit(context, tax);
                if (updatedTax != null) {
                  // Handle externally
                }
              },
            ),
          ),
        );
      },
    );
  }
}
