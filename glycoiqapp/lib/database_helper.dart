import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = await getDatabasesPath();
    final dbPath = join(path, 'glycoiQ.db');

    return await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE emergency_contacts (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            phone TEXT NOT NULL,
            rel TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE glucose_history (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT NOT NULL,
            glucose TEXT NOT NULL
          )
        ''');
      },
    );
  }

  // Insert Emergency Contact
  Future<void> insertContact(String name, String phone, String rel) async {
    final db = await database;
    await db.insert(
      'emergency_contacts',
      {'name': name, 'phone': phone, 'rel': rel},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Fetch Emergency Contacts
  Future<List<Map<String, dynamic>>> getContacts() async {
    final db = await database;
    return await db.query('emergency_contacts');
  }

  // Delete Contact
  Future<void> deleteContact(int id) async {
    final db = await database;
    await db.delete('emergency_contacts', where: 'id = ?', whereArgs: [id]);
  }

  // Insert Glucose Data
  Future<void> insertGlucose(String date, String glucose) async {
    final db = await database;
    await db.insert(
      'glucose_history',
      {'date': date, 'glucose': glucose},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Fetch Glucose History
  Future<List<Map<String, dynamic>>> getHistory() async {
    final db = await database;
    return await db.query('glucose_history', orderBy: 'date DESC');
  }
}
