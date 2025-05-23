// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:subha_medicals/db/repositories/organisations_repository.dart';
import 'package:subha_medicals/db/repositories/states_repository.dart';
import 'package:subha_medicals/models/organisation/organisation_class_model.dart';
import 'package:subha_medicals/models/state/state_class_model.dart';

class OrganisationForm extends StatefulWidget {
  final Organisation? organisation; // Edit mode if not null
  final bool? isBillerMode; // Optional for add mode

  const OrganisationForm({Key? key, this.organisation, this.isBillerMode})
    : super(key: key);

  @override
  _OrganisationFormState createState() => _OrganisationFormState();
}

class _OrganisationFormState extends State<OrganisationForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _contactController;
  late TextEditingController _address1Controller;
  late TextEditingController _address2Controller;
  late TextEditingController _pincodeController;
  late TextEditingController _emailController;
  late TextEditingController _mobileController;
  late TextEditingController _gstController;
  int? _selectedStateId;
  bool _isBiller = false;
  List<Province> _states = [];

  @override
  void initState() {
    super.initState();
    _loadStates();

    _nameController = TextEditingController(
      text: widget.organisation?.organisationName ?? '',
    );
    _contactController = TextEditingController(
      text: widget.organisation?.contactPerson ?? '',
    );
    _address1Controller = TextEditingController(
      text: widget.organisation?.addressLine1 ?? '',
    );
    _address2Controller = TextEditingController(
      text: widget.organisation?.addressLine2 ?? '',
    );
    _pincodeController = TextEditingController(
      text: widget.organisation?.pincode ?? '',
    );
    _emailController = TextEditingController(
      text: widget.organisation?.emailAddress ?? '',
    );
    _mobileController = TextEditingController(
      text: widget.organisation?.mobileNumber ?? '',
    );
    _gstController = TextEditingController(
      text: widget.organisation?.gstNumber ?? '',
    );
    _selectedStateId = widget.organisation?.stateId;

    // In edit mode, use model's value; in add mode, use optional param or default
    _isBiller = widget.organisation?.isBiller ?? widget.isBillerMode ?? false;
  }

  Future<void> _loadStates() async {
    final states = await StateRepository.getStates();
    setState(() => _states = states);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _address1Controller.dispose();
    _address2Controller.dispose();
    _pincodeController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _gstController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate() || _selectedStateId == null) return;

    final newOrg = Organisation(
      organisationId: widget.organisation?.organisationId,
      organisationName: _nameController.text.trim(),
      contactPerson: _contactController.text.trim(),
      addressLine1: _address1Controller.text.trim(),
      addressLine2: _address2Controller.text.trim(),
      stateId: _selectedStateId!,
      pincode: _pincodeController.text.trim(),
      emailAddress: _emailController.text.trim(),
      mobileNumber: _mobileController.text.trim(),
      gstNumber: _gstController.text.trim(),
      isBiller: _isBiller,
    );

    if (widget.organisation == null) {
      await OrganisationRepository.addOrganisation(newOrg);
    } else {
      await OrganisationRepository.updateOrganisation(newOrg);
    }

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.organisation != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Organisation' : 'Add Organisation'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Organisation Name'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
                maxLength: 200,
              ),
              TextFormField(
                controller: _contactController,
                maxLength: 200,
                decoration: InputDecoration(labelText: 'Contact Person'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _address1Controller,
                maxLength: 200,
                decoration: InputDecoration(labelText: 'Address Line 1'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _address2Controller,
                maxLength: 200,
                decoration: InputDecoration(labelText: 'Address Line 2'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              DropdownButtonFormField<int>(
                value: _selectedStateId,
                decoration: InputDecoration(labelText: 'State'),
                items:
                    _states
                        .map(
                          (s) => DropdownMenuItem(
                            value: s.state_id,
                            child: Text(s.state_name),
                          ),
                        )
                        .toList(),
                onChanged: (value) => setState(() => _selectedStateId = value),
                validator:
                    (value) => value == null ? 'Please select a state' : null,
              ),
              TextFormField(
                controller: _pincodeController,
                decoration: InputDecoration(labelText: 'Pincode'),
                keyboardType: TextInputType.number,
                maxLength: 6,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a pincode';
                  }
                  if (!RegExp(r'^[1-9][0-9]{5}$').hasMatch(value)) {
                    return 'Enter a valid 6-digit Indian pincode';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email Address'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email address';
                  }
                  if (!RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$',
                  ).hasMatch(value)) {
                    return 'Enter a valid email address';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _mobileController,
                decoration: InputDecoration(labelText: 'Phone Number(s)'),

                maxLength: 40,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter at least one phone number';
                  }

                  if (value.length < 10 || value.length > 40) {
                    return 'Enter between 10 and 40 characters';
                  }

                  final numbers =
                      value.split(',').map((e) => e.trim()).toList();
                  final mobileRegex = RegExp(r'^(\+91[\s-]?)?[6-9]\d{9}$');
                  final landlineRegex = RegExp(r'^0\d{2,4}[\s-]?\d{6,8}$');

                  for (var number in numbers) {
                    if (!(mobileRegex.hasMatch(number) ||
                        landlineRegex.hasMatch(number))) {
                      return 'Invalid number format: $number';
                    }
                  }

                  return null;
                },
              ),
              TextFormField(
                controller: _gstController,
                decoration: InputDecoration(labelText: 'GST Number'),
                maxLength: 15,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a GST number';
                  }
                  if (value.length != 15) {
                    return 'GST number must be exactly 15 characters';
                  }

                  // Basic GST format check (optional but recommended)
                  final gstRegex = RegExp(
                    r'^\d{2}[A-Z]{5}\d{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$',
                  );
                  if (!gstRegex.hasMatch(value)) {
                    return 'Invalid GST number format';
                  }

                  if (_selectedStateId == null) {
                    return 'Please select a state';
                  }

                  // Find the selected state from your list
                  final selectedState = _states.firstWhere(
                    (state) => state.state_id == _selectedStateId,
                    orElse:
                        () => Province(
                          state_id: 0,
                          state_name: '',
                          state_code: 0,
                        ),
                  );
                  if (selectedState == null) {
                    return 'Selected state is invalid';
                  }

                  // Convert state_code (int) to 2-digit string with leading zero if needed
                  final stateCodeStr = selectedState.state_code
                      .toString()
                      .padLeft(2, '0');

                  // Extract first two digits of GST number
                  final gstStateCode = value.substring(0, 2);

                  if (gstStateCode != stateCodeStr) {
                    return 'GST number should start with state code $stateCodeStr';
                  }

                  return null; // Passed validation
                },
              ),

              Text(
                _isBiller
                    ? (isEditMode ? 'This is a Biller' : 'Adding as Biller')
                    : (isEditMode
                        ? 'This is a Customer'
                        : 'Adding as Customer'),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text(isEditMode ? 'Update' : 'Add'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
