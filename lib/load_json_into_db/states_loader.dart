import 'dart:convert';
import 'package:flutter/services.dart';

import 'package:subha_medicals/db/db_manager/db_manager_general_initialisation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:subha_medicals/models/state/state_class_model.dart';

Future<void> loadStatesFromJson() async {
  final db = await DBManager.database;

  final List<Map<String, dynamic>> existing = await db.query('States');
  if (existing.isNotEmpty) {
    print("States already exist, skipping JSON load.");
    return;
  }

  print("Loading States from JSON...");
  final String jsonString = await rootBundle.loadString('assets/states.json');
  final List<dynamic> stateList = json.decode(jsonString);

  for (var item in stateList) {
    try {
      final state = Province(
        state_name: item['stateName'],
        state_code: item['stateCode'],
      );

      await db.insert(
        'States',
        state.toMap(), //using the tomap from class state
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    } catch (e) {
      print("Error inserting States: $e");
    }
  }

  print("States loaded from JSON and inserted into DB.");
}
