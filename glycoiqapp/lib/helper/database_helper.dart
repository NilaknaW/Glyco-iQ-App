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
    // print("inside initDatabase()");
    final path = await getDatabasesPath();
    // print("path: $path");
    final dbPath = join(path, 'glycoiQ.db');
    // await deleteDatabase(dbPath); // Delete this line after first run

    return await openDatabase(
      dbPath,
      version: 3, // Updated version number
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
            time TEXT NOT NULL,
            glucose TEXT NOT NULL
          )
        ''');

        await db.insert('glucose_history',
            {'date': '2025-03-07', 'time': '08:00 AM', 'glucose': '5.1'});
        await db.insert('glucose_history',
            {'date': '2025-03-08', 'time': '06:30 AM', 'glucose': '6.2'});
        await db.insert('glucose_history',
            {'date': '2025-03-09', 'time': '08:00 AM', 'glucose': '5.8'});
        await db.insert('glucose_history',
            {'date': '2025-03-10', 'time': '06:30 AM', 'glucose': '6.2'});
        await db.insert('glucose_history',
            {'date': '2025-03-11', 'time': '08:00 AM', 'glucose': '4.9'});
        await db.insert('glucose_history',
            {'date': '2025-03-12', 'time': '06:30 AM', 'glucose': '4.5'});
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
              "ALTER TABLE glucose_history ADD COLUMN time TEXT NOT NULL DEFAULT ''");
        }
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
  Future<void> insertGlucose(String date, String time, String glucose) async {
    final db = await database;
    await db.insert(
      'glucose_history',
      {'date': date, 'time': time, 'glucose': glucose},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Fetch Glucose History
  Future<List<Map<String, dynamic>>> getHistory() async {
    final db = await database;
    // final data =
    //     await db.query('glucose_history', orderBy: 'date DESC, time DESC');
    // print('Loaded glucose history: $data');
    return await db.query('glucose_history', orderBy: 'date DESC, time DESC');
  }

  // Fetch last Glucose entry
  Future<Map<String, dynamic>> getLastGlucose() async {
    final db = await database;
    final data = await db.query('glucose_history',
        orderBy: 'date DESC, time DESC', limit: 1);
    if (data.isNotEmpty) {
      return data.first;
    } else {
      return {}; // Return an empty map if no data is found
    }
  }
}
