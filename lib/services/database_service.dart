import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:path/path.dart';
import '../models/habit_entry.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    
    // Initialize database factory for web before opening database
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
    }
    
    _database = await _initDB('habits.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    if (kIsWeb) {
      // Use sqflite_common_ffi_web for web platform
      return await databaseFactory.openDatabase(
        filePath,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: _createDB,
        ),
      );
    } else {
      // Use regular sqflite for mobile/desktop
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, filePath);

      return await openDatabase(
        path,
        version: 1,
        onCreate: _createDB,
      );
    }
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE habit_entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        drinkWater INTEGER NOT NULL,
        eatHealthy INTEGER NOT NULL,
        exercise INTEGER NOT NULL,
        journal INTEGER NOT NULL,
        month TEXT NOT NULL,
        noPornAlcohol INTEGER NOT NULL,
        planTomorrow INTEGER NOT NULL,
        progressBar TEXT NOT NULL,
        read INTEGER NOT NULL,
        sleep INTEGER NOT NULL,
        socialMedia INTEGER NOT NULL,
        study INTEGER NOT NULL,
        dailyPercentage INTEGER NOT NULL,
        notes TEXT NOT NULL,
        UNIQUE(date)
      )
    ''');

    await db.execute('''
      CREATE TABLE habit_names (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        position INTEGER NOT NULL
      )
    ''');
  }

  // Habit Entries CRUD
  Future<int> insertHabitEntry(HabitEntry entry) async {
    final db = await database;
    return await db.insert(
      'habit_entries',
      _habitEntryToMap(entry),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<HabitEntry>> getAllHabitEntries() async {
    final db = await database;
    final maps = await db.query('habit_entries', orderBy: 'date DESC');
    return maps.map((map) => _mapToHabitEntry(map)).toList();
  }

  Future<HabitEntry?> getHabitEntry(DateTime date) async {
    final db = await database;
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    final maps = await db.query(
      'habit_entries',
      where: 'date = ?',
      whereArgs: [dateStr],
    );
    if (maps.isNotEmpty) {
      return _mapToHabitEntry(maps.first);
    }
    return null;
  }

  Future<int> updateHabitEntry(HabitEntry entry) async {
    final db = await database;
    final dateStr = DateFormat('yyyy-MM-dd').format(entry.date);
    return await db.update(
      'habit_entries',
      _habitEntryToMap(entry),
      where: 'date = ?',
      whereArgs: [dateStr],
    );
  }

  Future<int> deleteHabitEntry(DateTime date) async {
    final db = await database;
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    return await db.delete(
      'habit_entries',
      where: 'date = ?',
      whereArgs: [dateStr],
    );
  }

  // Habit Names CRUD
  Future<int> insertHabitName(String name, int position) async {
    final db = await database;
    return await db.insert('habit_names', {
      'name': name,
      'position': position,
    });
  }

  Future<List<String>> getAllHabitNames() async {
    final db = await database;
    final maps = await db.query('habit_names', orderBy: 'position ASC');
    return maps.map((map) => map['name'] as String).toList();
  }

  Future<void> saveHabitNames(List<String> names) async {
    final db = await database;
    await db.delete('habit_names');
    for (int i = 0; i < names.length; i++) {
      await insertHabitName(names[i], i);
    }
  }

  Future<int> deleteHabitName(String name) async {
    final db = await database;
    return await db.delete(
      'habit_names',
      where: 'name = ?',
      whereArgs: [name],
    );
  }

  // Helper methods
  Map<String, dynamic> _habitEntryToMap(HabitEntry entry) {
    return {
      'date': DateFormat('yyyy-MM-dd').format(entry.date),
      'drinkWater': entry.drinkWater ? 1 : 0,
      'eatHealthy': entry.eatHealthy ? 1 : 0,
      'exercise': entry.exercise ? 1 : 0,
      'journal': entry.journal ? 1 : 0,
      'month': entry.month,
      'noPornAlcohol': entry.noPornAlcohol ? 1 : 0,
      'planTomorrow': entry.planTomorrow ? 1 : 0,
      'progressBar': entry.progressBar,
      'read': entry.read ? 1 : 0,
      'sleep': entry.sleep ? 1 : 0,
      'socialMedia': entry.socialMedia ? 1 : 0,
      'study': entry.study ? 1 : 0,
      'dailyPercentage': entry.dailyPercentage,
      'notes': entry.notes,
    };
  }

  HabitEntry _mapToHabitEntry(Map<String, dynamic> map) {
    return HabitEntry(
      date: DateFormat('yyyy-MM-dd').parse(map['date'] as String),
      drinkWater: (map['drinkWater'] as int) == 1,
      eatHealthy: (map['eatHealthy'] as int) == 1,
      exercise: (map['exercise'] as int) == 1,
      journal: (map['journal'] as int) == 1,
      month: map['month'] as String,
      noPornAlcohol: (map['noPornAlcohol'] as int) == 1,
      planTomorrow: (map['planTomorrow'] as int) == 1,
      progressBar: map['progressBar'] as String,
      read: (map['read'] as int) == 1,
      sleep: (map['sleep'] as int) == 1,
      socialMedia: (map['socialMedia'] as int) == 1,
      study: (map['study'] as int) == 1,
      dailyPercentage: map['dailyPercentage'] as int,
      notes: map['notes'] as String,
    );
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
