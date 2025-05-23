import 'dart:convert';
import 'package:flutter/services.dart';

import 'package:subha_medicals/db/db_manager/db_manager_general_initialisation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:subha_medicals/models/tax_code/tax_code_class_model.dart';

Future<void> loadTaxCodesFromJson({
  Function(int current, int total)? onProgress,
}) async {
  final db = await DBManager.database;

  final List<Map<String, dynamic>> existing = await db.query('TaxCodes');
  if (existing.isNotEmpty) {
    print("TaxCodes already exist, skipping JSON load.");
    onProgress?.call(1, 1); // Immediately report 100%
    return;
  }

  print("Loading tax codes from JSON...");
  final String jsonString = await rootBundle.loadString('assets/taxcodes.json');
  final List<dynamic> taxCodeList = json.decode(jsonString);

  final int totalItems = taxCodeList.length;

  for (int i = 0; i < totalItems; i++) {
    var item = taxCodeList[i];
    try {
      final taxCode = TaxCode(
        taxCode:
            (item['TaxCode']?.toString().trim().isNotEmpty == true)
                ? item['TaxCode'].toString().trim()
                : '0',

        description: item['Description'],
        isHSN: int.tryParse(item['isHSN'].toString()) ?? 0,
        isActive: int.tryParse(item['isActive'].toString()) ?? 0,
        cgst:
            (item.containsKey('CGST') && item['CGST'] != null)
                ? (item['CGST'] as num).toDouble()
                : 0.0,
        sgst:
            (item.containsKey('SGST') && item['SGST'] != null)
                ? (item['SGST'] as num).toDouble()
                : 0.0,
        igst:
            (item.containsKey('IGST') && item['IGST'] != null)
                ? (item['IGST'] as num).toDouble()
                : 0.0,
        cess:
            (item.containsKey('Cess') && item['Cess'] != null)
                ? (item['Cess'] as num).toDouble()
                : 0.0,
      );

      await db.insert(
        'TaxCodes',
        taxCode.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    } catch (e) {
      print("Error inserting tax code: $e");
    }

    // Report progress after each insert
    if (onProgress != null) {
      onProgress(i + 1, totalItems);
    }
  }

  print("TaxCodes loaded from JSON and inserted into DB.");
}
