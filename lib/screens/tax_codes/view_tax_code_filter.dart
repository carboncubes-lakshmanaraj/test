import 'package:flutter/material.dart';
import 'package:subha_medicals/models/tax_code/tax_code_class_model.dart';
import 'package:subha_medicals/db/repositories/tax_code_repository.dart';
import 'package:subha_medicals/screens/tax_codes/edit_tax_values_bottommodalsheet.dart';
import 'package:subha_medicals/widgets/view_tax_codes_filter/tax_code_activefilter.dart';
import 'package:subha_medicals/widgets/view_tax_codes_filter/tax_code_filterhsn.dart';
import 'package:subha_medicals/widgets/view_tax_codes_filter/tax_code_listview.dart';
import 'package:subha_medicals/widgets/view_tax_codes_filter/view_tax_searchbar.dart';

enum TaxCodeFilter { all, hsn, sac } //for hsn,sac filter

enum ActiveFilter { all, active, inactive }
//for activie inactive filter

typedef OnTaxCodeSelected = void Function(TaxCode? taxCode);

class TaxCodeListWithFilterScreen extends StatefulWidget {
  @override
  State<TaxCodeListWithFilterScreen> createState() =>
      _TaxCodeListWithFilterScreenState();
}

class _TaxCodeListWithFilterScreenState
    extends State<TaxCodeListWithFilterScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose(); // Important to avoid memory leaks
    super.dispose();
  }

  List<TaxCode> _allTaxCodes = [];
  List<TaxCode> _filteredTaxCodes = [];
  TaxCodeFilter _selectedFilter = TaxCodeFilter.all;
  bool _isLoading = true;
  TaxCode? _selectedTaxCode;
  ActiveFilter _activeFilter = ActiveFilter.all; //defaultfor isActive

  @override
  void initState() {
    super.initState();
    _loadTaxCodes();
  }

  Future<void> _loadTaxCodes() async {
    final allCodes = await TaxCodeRepository.getTaxCodes();
    setState(() {
      _allTaxCodes = allCodes.toList();
      _applyFilter();
      _isLoading = false;
    });
  }

  void _applyFilter() {
    List<TaxCode> filtered;
    switch (_selectedFilter) {
      case TaxCodeFilter.hsn:
        filtered = _allTaxCodes.where((code) => code.isHSN == 1).toList();
        break;
      case TaxCodeFilter.sac:
        filtered = _allTaxCodes.where((code) => code.isHSN == 0).toList();
        break;
      case TaxCodeFilter.all:
      default:
        filtered = List.from(_allTaxCodes);
        break;
    }

    // Apply Active filter
    switch (_activeFilter) {
      case ActiveFilter.active:
        filtered = filtered.where((code) => code.isActive == 1).toList();
        break;
      case ActiveFilter.inactive:
        filtered = filtered.where((code) => code.isActive == 0).toList();
        break;
      case ActiveFilter.all:
      default:
        break;
    }

    setState(() {
      _filteredTaxCodes = filtered;
      if (_selectedTaxCode != null &&
          !_filteredTaxCodes.any(
            (t) => t.taxCode == _selectedTaxCode!.taxCode,
          )) {
        _selectedTaxCode = null;
      }
    });
  }

  void _onActiveFilterChanged(ActiveFilter? filter) {
    //isactive filter
    if (filter == null) return;
    setState(() {
      _activeFilter = filter;
      _applyFilter();
    });
  }

  void _onHSNFilterChanged(TaxCodeFilter? filter) {
    //hsn/sac filter
    if (filter == null) return;
    setState(() {
      _selectedFilter = filter;
      _applyFilter();
    });
  }

  void _onSearchSelected(TaxCode? selected) {
    if (selected == null) {
      setState(() {
        _applyFilter();
      });
    } else {
      setState(() {
        _filteredTaxCodes = [selected];
        _selectedFilter = TaxCodeFilter.all;
        _selectedTaxCode = selected;
      });
    }
  }

  void _onListItemTapped(TaxCode tax) {
    setState(() {
      _selectedTaxCode = tax;
    });
  }

  String _getFilterText(TaxCodeFilter filter) {
    switch (filter) {
      case TaxCodeFilter.hsn:
        return 'HSN (Goods & Services)';
      case TaxCodeFilter.sac:
        return 'SAC (Services Only)';
      case TaxCodeFilter.all:
      default:
        return 'All';
    }
  }

  String _getActiveFilterText(ActiveFilter filter) {
    switch (filter) {
      case ActiveFilter.active:
        return 'Active Only';
      case ActiveFilter.inactive:
        return 'Inactive Only';
      case ActiveFilter.all:
      default:
        return 'All (Active & Inactive)';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tax Codes with Filter')),
      body: Scrollbar(
        thumbVisibility: true, // Always show the scrollbar
        interactive: true, // enables dragging
        controller: _scrollController,
        thickness: 10.0, // Adjust thickness (default is 6.0)
        radius: Radius.circular(8),
        child: SingleChildScrollView(
          controller: _scrollController,
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.86,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TaxCodeSearchBar(
                    taxCodes: _allTaxCodes,
                    onSelected: _onSearchSelected,
                  ),
                ),

                // Dropdown with radio options
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: TaxCodeFilterDropdown(
                          selectedFilter: _selectedFilter,
                          onFilterChanged: _onHSNFilterChanged,
                          getFilterText: _getFilterText,
                        ),
                      ),
                    ),

                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 8,
                        ),
                        child: ActiveFilterDropdown(
                          selectedFilter: _activeFilter,
                          onFilterChanged: _onActiveFilterChanged,
                          getFilterText: _getActiveFilterText,
                        ),
                      ),
                    ),
                  ],
                ),

                const Divider(),

                Expanded(
                  child: TaxCodeListView(
                    isLoading: _isLoading,
                    filteredTaxCodes: _filteredTaxCodes,
                    selectedTaxCode: _selectedTaxCode,
                    onListItemTapped: _onListItemTapped,
                    onEdit: (context, tax) async {
                      final updatedTax = await showEditTaxCodeBottomSheet(
                        context: context,
                        tax: tax,
                      );
                      if (updatedTax != null) {
                        _loadTaxCodes(); // reload after successful update
                      }
                      return updatedTax;
                    },
                  ),
                ),

                if (_selectedTaxCode != null)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Selected Tax:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text('Code: ${_selectedTaxCode!.taxCode}'),
                        Text('Description: ${_selectedTaxCode!.description}'),
                      ],
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
