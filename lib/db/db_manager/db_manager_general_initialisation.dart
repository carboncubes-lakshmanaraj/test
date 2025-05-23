// db_manager.dart
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';

class DBManager {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  static Future<void> requestStoragePermission() async {
    await Permission.storage.request();
  }

  static Future<String> getDatabasePath() async {
    Directory? extDir = await getExternalStorageDirectory();
    return join(extDir!.path, "SubhaMedicals.db");
  }

  static Future<Database> _initDB() async {
    await requestStoragePermission();
    String path = await getDatabasePath();

    return await openDatabase(
      path,
      version: 1,
      // Enable foreign key constraints
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS States (
            StateID INTEGER PRIMARY KEY AUTOINCREMENT,
            StateName TEXT NOT NULL,
            StateCode INTEGER NOT NULL UNIQUE
          );
        ''');

        // await db.execute('''
        //   CREATE TABLE IF NOT EXISTS Taxes (
        //     TaxID INTEGER PRIMARY KEY AUTOINCREMENT,
        //     TaxTitle TEXT NOT NULL,
        //     TaxPercentage REAL NOT NULL
        //   );
        // ''');

        await db.execute('''
 CREATE TABLE IF NOT EXISTS TaxCodes (
  TaxCodeID INTEGER PRIMARY KEY AUTOINCREMENT,
  TaxCode TEXT NOT NULL UNIQUE,
  Description TEXT,
   IsHSN INTEGER NOT NULL CHECK (IsHSN IN (0, 1)),               
  IsActive INTEGER NOT NULL DEFAULT 0 CHECK (IsActive IN (0, 1)),
  CGST REAL NOT NULL DEFAULT 0,
  SGST REAL NOT NULL DEFAULT 0,
  IGST REAL NOT NULL DEFAULT 0,
  Cess REAL NOT NULL DEFAULT 0
);
''');

        await db.execute('''
CREATE TABLE Organisations (
    OrganisationID INTEGER PRIMARY KEY AUTOINCREMENT,
    OrganisationName VARCHAR(500) NOT NULL,
    ContactPerson VARCHAR(250),
    AddressLine1 VARCHAR(250) NOT NULL,
    AddressLine2 VARCHAR(250),
    
    StateID INTEGER NOT NULL,
    Pincode VARCHAR(6),
    EmailAddress VARCHAR(500),
    MobileNumber VARCHAR(40),
    GSTNumber VARCHAR(100), 
   IsBiller INTEGER NOT NULL DEFAULT 0 CHECK (IsBiller IN (0, 1)),-- Use 1 for Biller, 0 for Customer
    FOREIGN KEY (StateID) REFERENCES States(StateID)
);
''');
      },
    );
  }
}
