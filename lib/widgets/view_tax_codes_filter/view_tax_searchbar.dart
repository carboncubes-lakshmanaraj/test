import 'package:flutter/material.dart';
import 'package:subha_medicals/models/tax_code/tax_code_class_model.dart';
import 'package:subha_medicals/db/repositories/tax_code_repository.dart';
import 'package:subha_medicals/screens/tax_codes/view_tax_code_filter.dart';

class TaxCodeSearchBar extends StatefulWidget {
  final List<TaxCode> taxCodes;
  final OnTaxCodeSelected? onSelected;

  const TaxCodeSearchBar({Key? key, required this.taxCodes, this.onSelected})
    : super(key: key);

  @override
  _TaxCodeSearchBarState createState() => _TaxCodeSearchBarState();
}

class _TaxCodeSearchBarState extends State<TaxCodeSearchBar> {
  final TextEditingController _controller = TextEditingController();
  List<TaxCode> _suggestions = [];
  void _onTextChanged(String query) {
    final trimmedQuery = query.trim().toLowerCase();

    if (trimmedQuery.isEmpty) {
      setState(() {
        _suggestions = [];
      });
      widget.onSelected?.call(null);
      return;
    }

    final isNumeric = RegExp(r'^\d+$').hasMatch(trimmedQuery);

    List<TaxCode> startsWithMatches = [];
    List<TaxCode> containsMatches = [];

    for (var tax in widget.taxCodes) {
      final taxCodeStr = tax.taxCode.toString().toLowerCase();
      final description = tax.description.toLowerCase();

      if (isNumeric) {
        if (taxCodeStr.startsWith(trimmedQuery)) {
          startsWithMatches.add(tax);
        } else if (taxCodeStr.contains(trimmedQuery)) {
          containsMatches.add(tax);
        }
      } else {
        if (description.startsWith(trimmedQuery)) {
          startsWithMatches.add(tax);
        } else if (description.contains(trimmedQuery)) {
          containsMatches.add(tax);
        }
      }
    }

    setState(() {
      _suggestions = [...startsWithMatches, ...containsMatches];
    });
  }

  void _onSuggestionTap(TaxCode taxCode) {
    _controller.text = taxCode.taxCode.toString();
    setState(() {
      _suggestions = [];
    });
    widget.onSelected?.call(taxCode);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controller,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search),
            hintText: 'Search tax codes...',
            border: const OutlineInputBorder(),
            suffixIcon:
                _controller.text.isNotEmpty
                    ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _controller.clear();
                        _onTextChanged('');
                        widget.onSelected?.call(null);
                      },
                    )
                    : null,
          ),

          onChanged: _onTextChanged,
        ),
        if (_suggestions.isNotEmpty)
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color.fromARGB(94, 201, 206, 233),
                  Color.fromARGB(113, 63, 81, 181),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              // border: Border(
              //   left: BorderSide(color: Colors.blueAccent, width: 2),
              //   right: BorderSide(color: Colors.blueAccent, width: 2),
              //   bottom: BorderSide(color: Colors.blueAccent, width: 2),
              //   top: BorderSide.none, // No top border
              // ),
            ),
            constraints: const BoxConstraints(maxHeight: 200),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _suggestions.length,
              itemBuilder: (context, index) {
                final tax = _suggestions[index];
                return Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: const Color.fromARGB(255, 0, 0, 0),
                        width: 2,
                      ),
                    ),
                  ),
                  child: ListTile(
                    title: Text('${tax.taxCode} - ${tax.description}'),
                    onTap: () => _onSuggestionTap(tax),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
