import 'package:flutter/material.dart';
import 'package:subha_medicals/db/repositories/tax_code_repository.dart';
import 'package:subha_medicals/models/tax_code/tax_code_class_model.dart';

Future<TaxCode?> showEditTaxCodeBottomSheet({
  required BuildContext context,
  required TaxCode tax,
}) async {
  final _codeSGSTController = TextEditingController(text: tax.sgst.toString());
  final _codeCGSTController = TextEditingController(text: tax.cgst.toString());
  final _codeIGSTController = TextEditingController(text: tax.igst.toString());
  final _codeCESSController = TextEditingController(text: tax.cess.toString());

  bool _isLoading = false;
  bool _listenerAdded = false;
  bool _isUpdatingSGST = false;
  bool _isUpdatingCGST = false;

  bool isActive = tax.isActive == 1; // <-- New: initial switch state

  return await showModalBottomSheet<TaxCode>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          top: 16,
        ),
        child: StatefulBuilder(
          builder: (context, setState) {
            // Add sync listeners only once
            if (!_listenerAdded) {
              _listenerAdded = true;

              _codeSGSTController.addListener(() {
                if (!_isUpdatingCGST) {
                  _isUpdatingSGST = true;
                  _codeCGSTController.text = _codeSGSTController.text;
                  _isUpdatingSGST = false;
                }
              });

              _codeCGSTController.addListener(() {
                if (!_isUpdatingSGST) {
                  _isUpdatingCGST = true;
                  _codeSGSTController.text = _codeCGSTController.text;
                  _isUpdatingCGST = false;
                }
              });
            }

            Future<void> _submitUpdate() async {
              final SGST = double.tryParse(_codeSGSTController.text.trim());
              final CGST = double.tryParse(_codeCGSTController.text.trim());
              final IGST = double.tryParse(_codeIGSTController.text.trim());
              final CESS = double.tryParse(_codeCESSController.text.trim());

              if (SGST == null ||
                  CGST == null ||
                  IGST == null ||
                  CESS == null) {
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    behavior: SnackBarBehavior.floating,
                    margin: EdgeInsets.only(bottom: 80.0, left: 16, right: 16),
                    content: Text(
                      'All fields are required and must be valid numbers',
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              if (SGST != CGST) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('CGST and SGST should be same'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              final updatedTax = TaxCode(
                taxCodeId: tax.taxCodeId,
                taxCode: tax.taxCode,
                description: tax.description,
                sgst: SGST,
                cgst: CGST,
                igst: IGST,
                cess: CESS,
                isHSN: tax.isHSN,
                isActive: isActive ? 1 : 0, // <-- New: from switch
              );

              try {
                setState(() => _isLoading = true);
                final result = await TaxCodeRepository.updateTaxCode(
                  updatedTax,
                );

                if (result > 0) {
                  Navigator.pop(context, updatedTax);
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('TAX VALUES updated successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to update TAX values'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: ${e.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
              } finally {
                setState(() => _isLoading = false);
              }
            }

            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Edit TAX Values",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text("Tax Code: ${tax.taxCode}"),
                  Text("Description: ${tax.description}"),
                  const SizedBox(height: 16),

                  TextField(
                    controller: _codeSGSTController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(labelText: 'SGST'),
                  ),
                  TextField(
                    controller: _codeCGSTController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(labelText: 'CGST'),
                  ),
                  TextField(
                    controller: _codeIGSTController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(labelText: 'IGST'),
                  ),
                  TextField(
                    controller: _codeCESSController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(labelText: 'CESS'),
                  ),

                  const SizedBox(height: 16),

                  // Toggle switch for isActive
                  SwitchListTile(
                    title: const Text("Active"),
                    value: isActive,
                    onChanged: (value) {
                      setState(() {
                        isActive = value;
                      });
                    },
                    activeColor: Colors.green,
                  ),

                  const SizedBox(height: 32),

                  _isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                        onPressed: _submitUpdate,
                        child: const Text('Update TAX'),
                      ),

                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      );
    },
  );
}
