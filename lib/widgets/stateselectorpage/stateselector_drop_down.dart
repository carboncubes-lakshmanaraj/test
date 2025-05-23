import 'package:flutter/material.dart';

import 'package:subha_medicals/models/state/state_class_model.dart';
import 'package:subha_medicals/db/repositories/states_repository.dart';

class StateSelectorDropdown extends StatefulWidget {
  final int? selectedStateId;
  final Function(Province?) onStateSelected;

  const StateSelectorDropdown({
    Key? key,
    required this.selectedStateId,
    required this.onStateSelected,
  }) : super(key: key);

  @override
  _StateSelectorDropdownState createState() => _StateSelectorDropdownState();
}

class _StateSelectorDropdownState extends State<StateSelectorDropdown> {
  List<Province> _states = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStates();
  }

  Future<void> _fetchStates() async {
    try {
      // Fetch the states from the DBHelper
      final states = await StateRepository.getStates();
      setState(() {
        _states = states;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to load states: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : DropdownButton<int>(
          icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
          isExpanded: true,
          value: widget.selectedStateId,
          hint: const Text("Select a state"),
          items:
              _states.map((state) {
                return DropdownMenuItem<int>(
                  value: state.state_id,
                  child: Text("${state.state_name} (${state.state_code})"),
                );
              }).toList(),
          onChanged: (int? newId) {
            if (newId != null) {
              final selectedState = _states.firstWhere(
                (state) => state.state_id == newId,
              );
              widget.onStateSelected(
                selectedState,
              ); // Callback to send the selected state
            }
          },
        );
  }
}
