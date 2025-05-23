import 'package:flutter/material.dart';
import 'package:subha_medicals/db/repositories/organisations_repository.dart';
import 'package:subha_medicals/models/organisation/organisation_class_model.dart';
import 'package:subha_medicals/screens/organisations/form_for_organisation_add_update.dart';

class OrganisationListScreen extends StatefulWidget {
  const OrganisationListScreen({Key? key}) : super(key: key);

  @override
  _OrganisationListScreenState createState() => _OrganisationListScreenState();
}

class _OrganisationListScreenState extends State<OrganisationListScreen> {
  List<Organisation> _organisations = [];
  int? _filter;
  Organisation? _selectedOrganisation; // New state

  @override
  void initState() {
    super.initState();
    _loadOrganisations();
  }

  Future<void> _loadOrganisations() async {
    List<Organisation> all = await OrganisationRepository.getOrganisations();
    if (_filter != null) {
      all = all.where((org) => org.isBiller == (_filter == 1)).toList();
    }
    setState(() {
      _organisations = all;
      // _selectedOrganisation = null; // Clear selection on reload
    });
  }

  void _navigateToForm({Organisation? organisation}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OrganisationForm(organisation: organisation),
      ),
    );
    if (result == true) {
      _loadOrganisations();
    }
  }

  void _confirmDelete(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Confirm Delete'),
            content: const Text(
              'Are you sure you want to delete this organisation?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      await OrganisationRepository.deleteOrganisation(id);
      _loadOrganisations();
    }
  }

  Widget _buildFilterChips() {
    return Wrap(
      spacing: 8.0,
      children: [
        FilterChip(
          label: const Text('All'),
          selected: _filter == null,
          onSelected: (_) {
            setState(() {
              _filter = null;
              _loadOrganisations();
            });
          },
        ),
        FilterChip(
          label: const Text('Biller'),
          selected: _filter == 1,
          onSelected: (_) {
            setState(() {
              _filter = 1;
              _loadOrganisations();
            });
          },
        ),
        FilterChip(
          label: const Text('Customer'),
          selected: _filter == 0,
          onSelected: (_) {
            setState(() {
              _filter = 0;
              _loadOrganisations();
            });
          },
        ),
      ],
    );
  }

  Widget _buildSelectedInfo() {
    if (_selectedOrganisation == null) return const SizedBox();
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(12),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        border: Border.all(color: Colors.blue),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'Selected: ${_selectedOrganisation!.organisationName} (${_selectedOrganisation!.isBiller ? "IS Biller" : "IS Customer"})',
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Organisations')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            _buildFilterChips(),
            const SizedBox(height: 10),
            Expanded(
              child:
                  _organisations.isEmpty
                      ? const Center(child: Text('No organisations found.'))
                      : ListView.builder(
                        itemCount: _organisations.length,
                        itemBuilder: (_, index) {
                          final org = _organisations[index];
                          return InkWell(
                            onTap: () {
                              setState(() {
                                _selectedOrganisation = org;
                              });
                            },
                            child: Card(
                              child: ListTile(
                                title: Text(org.organisationName),
                                subtitle: Text(
                                  '${org.isBiller ? "Biller" : "Customer"}\n${org.addressLine1}',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                isThreeLine: true,
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed:
                                          () => _navigateToForm(
                                            organisation: org,
                                          ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed:
                                          () => _confirmDelete(
                                            org.organisationId!,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
            ),
            _buildSelectedInfo(), // Display selected item
          ],
        ),
      ),
    );
  }
}
