import 'package:flutter/material.dart';
import 'package:subha_medicals/models/state/state_class_model.dart';
import 'package:subha_medicals/widgets/stateselectorpage/stateselector_drop_down.dart';

class StateSelectorPage extends StatefulWidget {
  const StateSelectorPage({super.key});

  @override
  State<StateSelectorPage> createState() => _StateSelectorPageState();
}

class _StateSelectorPageState extends State<StateSelectorPage> {
  int? _selectedStateId;
  Province? _selectedState;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select a State')),
      body: Center(
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color.fromARGB(207, 63, 81, 181),
                  Color.fromARGB(255, 63, 81, 181),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: Colors.blueAccent, width: 2),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(16.0),
            constraints: const BoxConstraints(maxWidth: 300),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "Choose a state:",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                StateSelectorDropdown(
                  selectedStateId: _selectedStateId,
                  onStateSelected: (selectedState) {
                    setState(() {
                      _selectedState = selectedState;
                      _selectedStateId = selectedState?.state_id;
                    });
                  },
                ),
                const SizedBox(height: 20),
                if (_selectedState != null)
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        "Selected State:\n\n"
                        "ID: ${_selectedState!.state_id}\n"
                        "Name: ${_selectedState!.state_name}\n"
                        "Code: ${_selectedState!.state_code}",
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
