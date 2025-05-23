// state_repository.dart
import 'package:subha_medicals/db/db_manager/db_manager_general_initialisation.dart';
import 'package:subha_medicals/models/state/state_class_model.dart';

class StateRepository {
  // Create

  static Future<int> addState(Province state) async {
    try {
      final db = await DBManager.database;
      return await db.insert('States', state.toMap());
    } catch (e) {
      print("Error adding state: $e");
      return -1;
    }
  }

  // Read All
  static Future<List<Province>> getStates() async {
    final db = await DBManager.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'States',
      orderBy: 'StateCode',
    );
    return maps.map((map) => Province.fromMap(map)).toList();
  }

  // Read by ID
  static Future<Province?> getStateById(int id) async {
    final db = await DBManager.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'States',
      where: 'StateID = ?',
      whereArgs: [id],
    );
    return maps.isNotEmpty ? Province.fromMap(maps.first) : null;
  }

  // Update
  static Future<int> updateState(Province state) async {
    final db = await DBManager.database;
    return await db.update(
      'States',
      state.toMap(),
      where: 'StateID = ?',
      whereArgs: [state.state_id],
    );
  }

  // Delete
  static Future<int> deleteState(int id) async {
    final db = await DBManager.database;
    return await db.delete('States', where: 'StateID = ?', whereArgs: [id]);
  }
}
