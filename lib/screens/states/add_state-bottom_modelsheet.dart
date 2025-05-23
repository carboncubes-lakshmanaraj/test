import 'package:flutter/material.dart';
import 'package:subha_medicals/models/state/state_class_model.dart';
import 'package:subha_medicals/db/repositories/states_repository.dart';

Future<bool?> showAddStateBottomSheet(BuildContext context) async {
  final _stateNameController = TextEditingController();
  final _stateCodeController = TextEditingController();
  bool _isLoading = false;

  return await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
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
            Future<void> _addState() async {
              final name = _stateNameController.text.trim();
              final code = _stateCodeController.text.trim();

              int? parsedCode = int.tryParse(code);

              if (parsedCode == null) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Code must be a valid integer'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              if (name.isNotEmpty && code.isNotEmpty) {
                setState(() => _isLoading = true);
                try {
                  final newState = Province(
                    state_name: name,
                    state_code: int.parse(code),
                  );
                  final result = await StateRepository.addState(newState);

                  if (result > 0) {
                    _stateNameController.clear();
                    _stateCodeController.clear();
                    Navigator.pop(context, true); // Return true

                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        behavior: SnackBarBehavior.floating, // Important!

                        content: Text("State added successfully"),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("State already exists or failed to add"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } catch (e) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Failed to add state: $e"),
                      backgroundColor: Colors.red,
                    ),
                  );
                } finally {
                  setState(() => _isLoading = false);
                }
              }
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Add State"),
                TextField(
                  controller: _stateNameController,
                  decoration: InputDecoration(labelText: 'State Name'),
                ),
                TextField(
                  controller: _stateCodeController,
                  decoration: InputDecoration(labelText: 'State Code'),
                ),
                const SizedBox(height: 50),
                _isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                      onPressed: _addState,
                      child: Text("Add State"),
                    ),
                SizedBox(height: 50),
              ],
            );
          },
        ),
      );
    },
  );
}
