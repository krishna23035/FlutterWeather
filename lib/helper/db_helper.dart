import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class LocationDatabase {
  static final LocationDatabase instance = LocationDatabase._init();

  static Database? _database;

  LocationDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('locations.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE locations(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE weather(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        location_id INTEGER,
        temperature REAL NOT NULL,
        timestamp INTEGER NOT NULL
        FOREIGN KEY (location_id) REFERENCES location(id)
      )
    ''');
  }

  Future<int> insertLocation(String name) async {
    final db = await instance.database;

    return await db.insert('locations', {'name': name});
  }

  Future<List<String>> getLocations() async {
    final db = await instance.database;

    final List<Map<String, dynamic>> maps = await db.query('locations');

    return List.generate(maps.length, (i) => maps[i]['name'] as String);
  }

  Future<int> insertWeather(String locationId, double temperature) async {
    final db = await instance.database;
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    return await db.insert('weather', {
      'location_id': locationId,
      'temperature': temperature,
      'timestamp': timestamp,
    });
  }

  Future<List<Map<String, dynamic>>> getWeather(int locationId) async {
    final db = await instance.database;

    return await db.query(
      'weather',
      where: 'location_id = ?',
      whereArgs: [locationId],
    );
  }

  Future<void> deleteLocation(String name) async {
    final db = await instance.database;

    await db.delete(
      'locations',
      where: 'name = ?',
      whereArgs: [name],
    );
  }
}
