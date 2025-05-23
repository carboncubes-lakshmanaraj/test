import 'package:subha_medicals/db/db_manager/db_manager_general_initialisation.dart';
import 'package:subha_medicals/models/organisation/organisation_class_model.dart';

class OrganisationRepository {
  // Create
  static Future<int> addOrganisation(Organisation organisation) async {
    try {
      final db = await DBManager.database;
      return await db.insert('Organisations', organisation.toMap());
    } catch (e) {
      print("Error adding organisation: $e");
      return -1;
    }
  }

  // Read All
  static Future<List<Organisation>> getOrganisations() async {
    final db = await DBManager.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Organisations',
      orderBy: 'OrganisationName',
    );
    return maps.map((map) => Organisation.fromMap(map)).toList();
  }

  // Read by ID
  static Future<Organisation?> getOrganisationById(int id) async {
    final db = await DBManager.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Organisations',
      where: 'OrganisationID = ?',
      whereArgs: [id],
    );
    return maps.isNotEmpty ? Organisation.fromMap(maps.first) : null;
  }

  // Update
  static Future<int> updateOrganisation(Organisation organisation) async {
    final db = await DBManager.database;
    return await db.update(
      'Organisations',
      organisation.toMap(),
      where: 'OrganisationID = ?',
      whereArgs: [organisation.organisationId],
    );
  }

  // Delete
  static Future<int> deleteOrganisation(int id) async {
    final db = await DBManager.database;
    return await db.delete(
      'Organisations',
      where: 'OrganisationID = ?',
      whereArgs: [id],
    );
  }
}
