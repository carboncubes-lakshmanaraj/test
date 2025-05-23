import 'package:subha_medicals/db/db_manager/db_manager_general_initialisation.dart';
import 'package:subha_medicals/models/tax_code/tax_code_class_model.dart';

class TaxCodeRepository {
  // Create
  static Future<int> addTaxCode(TaxCode taxCode) async {
    try {
      final db = await DBManager.database;
      return await db.insert('TaxCodes', taxCode.toMap());
    } catch (e) {
      print("Error adding tax code: $e");
      return -1;
    }
  }

  // Read All
  static Future<List<TaxCode>> getTaxCodes() async {
    final db = await DBManager.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'TaxCodes',
      orderBy: 'TaxCode',
    );
    return maps.map((map) => TaxCode.fromMap(map)).toList();
  }

  // Read by ID
  static Future<TaxCode?> getTaxCodeById(int id) async {
    final db = await DBManager.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'TaxCodes',
      where: 'TaxCodeID = ?',
      whereArgs: [id],
    );
    return maps.isNotEmpty ? TaxCode.fromMap(maps.first) : null;
  }

  // Update
  static Future<int> updateTaxCode(TaxCode taxCode) async {
    final db = await DBManager.database;
    return await db.update(
      'TaxCodes',
      taxCode.toMap(),
      where: 'TaxCodeID = ?',
      whereArgs: [taxCode.taxCodeId],
    );
  }

  // Delete
  static Future<int> deleteTaxCode(int id) async {
    final db = await DBManager.database;
    return await db.delete('TaxCodes', where: 'TaxCodeID = ?', whereArgs: [id]);
  }
}
