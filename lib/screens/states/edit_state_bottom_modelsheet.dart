import 'package:flutter/material.dart';
import 'package:subha_medicals/models/state/state_class_model.dart';
import 'package:subha_medicals/db/repositories/states_repository.dart';

Future<Province?> showEditStateBottomSheet({
  required BuildContext context,
  required Province state,
}) async {
  final _nameController = TextEditingController(text: state.state_name);
  final _codeController = TextEditingController(
    text: state.state_code.toString(),
  );
  bool _isLoading = false;

  return await showModalBottomSheet(
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
            Future<void> _submitUpdate() async {
              final name = _nameController.text.trim();
              final code = _codeController.text.trim();

              if (name.isEmpty || code.isEmpty) {
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    behavior: SnackBarBehavior.floating, // Important!
                    margin: EdgeInsets.only(
                      bottom: 80.0, // Enough margin so it doesn't overlap FAB
                      left: 16,
                      right: 16,
                    ),
                    content: Text('All fields are required'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

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

              final updatedState = Province(
                state_id: state.state_id,
                state_name: name,
                state_code: parsedCode,
              );

              try {
                setState(() => _isLoading = true);
                final result = await StateRepository.updateState(updatedState);

                if (result > 0) {
                  Navigator.pop(context, updatedState);
                  ScaffoldMessenger.of(
                    context,
                  ).clearSnackBars(); // return true on success
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('State updated successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to update state'),
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

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Edit State"),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'State Name'),
                ),
                TextField(
                  controller: _codeController,
                  decoration: InputDecoration(labelText: 'State Code'),
                ),
                const SizedBox(height: 50),
                _isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                      onPressed: _submitUpdate,
                      child: Text('Update State'),
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
