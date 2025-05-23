import 'package:flutter/material.dart';
import 'package:subha_medicals/db/db_manager/db_manager_general_initialisation.dart';

import 'package:subha_medicals/models/state/state_class_model.dart';
import 'package:subha_medicals/db/repositories/states_repository.dart';
import 'package:subha_medicals/screens/states/add_state-bottom_modelsheet.dart';
import 'package:subha_medicals/screens/states/edit_state_bottom_modelsheet.dart';

import 'package:subha_medicals/utils/share_db_utility.dart';

class Listviewallstate extends StatefulWidget {
  const Listviewallstate({super.key});

  @override
  State<Listviewallstate> createState() => _ListviewallstateState();
}

class _ListviewallstateState extends State<Listviewallstate> {
  List<Province> _states = [];
  String? _dbPath;

  @override
  void initState() {
    super.initState();
    _loadStates();
    _loadDatabasePath();
  }

  Future<void> _loadDatabasePath() async {
    final path = await DBManager.getDatabasePath();
    setState(() {
      _dbPath = path;
    });
  }

  Future<void> _loadStates() async {
    final data = await StateRepository.getStates();
    setState(() {
      _states = data;
    });
  }

  Future<void> _deleteState(Province state) async {
    bool shouldDelete = await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Delete "${state.state_name}"?'),
            content: Text(
              'Are you sure you want to delete this state?\n\nCode: ${state.state_code}\nID: ${state.state_id}',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );

    if (shouldDelete) {
      try {
        await StateRepository.deleteState(state.state_id!);
        _loadStates();

        ScaffoldMessenger.of(
          context,
        ).clearSnackBars(); // Refresh the list after deleting
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${state.state_name} deleted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete state: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('States')),
      body:
          _states.isEmpty
              ? Center(child: Text('No states found.'))
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_dbPath != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          'DB Path: $_dbPath',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _states.length,
                        itemBuilder: (context, index) {
                          final state = _states[index];
                          return ListTile(
                            leading: Text('${index + 1}'),
                            title: Text(state.state_name),
                            subtitle: Text(
                              '${state.state_code} (ID: ${state.state_id})',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Delete icon
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteState(state),
                                ),
                                // Update icon
                                IconButton(
                                  icon: Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () async {
                                    final updatedState =
                                        await showEditStateBottomSheet(
                                          context: context,
                                          state: state,
                                        );

                                    if (updatedState != null) {
                                      // You got the full updated Province object!
                                      print(
                                        "Updated state: ${updatedState.state_name}",
                                      );
                                      _loadStates(); // or pass the updatedState to your list
                                    } // reload your states list
                                  },

                                  //  () async {
                                  //   final result = await Navigator.push(
                                  //     context,
                                  //     MaterialPageRoute(
                                  //       builder:
                                  //           (context) => EditStateScreen(
                                  //             stateId: state.state_id!,
                                  //             stateName: state.state_name,
                                  //             stateCode: state.state_code,
                                  //           ),
                                  //     ),
                                  //   );

                                  //   if (result != null && result is Province) {
                                  //     // Refresh the list after update
                                  //     setState(() {
                                  //       _states[_states.indexWhere(
                                  //             (s) =>
                                  //                 s.state_id == result.state_id,
                                  //           )] =
                                  //           result;
                                  //     });

                                  //     ScaffoldMessenger.of(
                                  //       context,
                                  //     ).showSnackBar(
                                  //       SnackBar(
                                  //         content: Text(
                                  //           'State updated successfully!',
                                  //         ),
                                  //         backgroundColor: Colors.green,
                                  //       ),
                                  //     );
                                  //   }
                                  // },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          try {
                            await ShareUtil.shareDatabase();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Database shared successfully!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Failed to share database: ${e.toString()}',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.share),
                        label: const Text("Share Db"),
                      ),
                    ),
                  ],
                ),
              ),
      // ✅ Floating Action Button added here
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 30.0), // Move FAB up by 30px
        child: FloatingActionButton(
          onPressed: () async {
            final added = await showAddStateBottomSheet(context);
            if (added == true) {
              _loadStates(); // Refresh only if a new state was added
            }
          },
          child: Icon(Icons.add),
          tooltip: 'Add State',
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
