import '../models/habit_entry.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static const String _entriesKey = 'habit_entries';
  static const String _namesKey = 'habit_names';

  DatabaseService._init();

  // CRUD operations
  Future<int> insertHabitEntry(HabitEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    final entries = await getAllHabitEntries();
    
    // Remove existing entry with same date if any
    entries.removeWhere((e) => 
      DateFormat('yyyy-MM-dd').format(e.date) == 
      DateFormat('yyyy-MM-dd').format(entry.date)
    );
    
    entries.add(entry);
    
    final jsonList = entries.map((e) => _habitEntryToMap(e)).toList();
    await prefs.setString(_entriesKey, jsonEncode(jsonList));
    return 1;
  }

  Future<List<HabitEntry>> getAllHabitEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_entriesKey);
    
    if (jsonStr == null) return [];
    
    final List<dynamic> jsonList = jsonDecode(jsonStr);
    final entries = jsonList.map((json) => _mapToHabitEntry(json)).toList();
    
    // Sort by date descending
    entries.sort((a, b) => b.date.compareTo(a.date));
    return entries;
  }

  Future<HabitEntry?> getHabitEntry(DateTime date) async {
    final entries = await getAllHabitEntries();
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    
    try {
      return entries.firstWhere((e) => 
        DateFormat('yyyy-MM-dd').format(e.date) == dateStr
      );
    } catch (e) {
      return null;
    }
  }

  Future<int> updateHabitEntry(HabitEntry entry) async {
    return await insertHabitEntry(entry); // Same as insert with replace logic
  }

  Future<int> deleteHabitEntry(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final entries = await getAllHabitEntries();
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    
    entries.removeWhere((e) => 
      DateFormat('yyyy-MM-dd').format(e.date) == dateStr
    );
    
    final jsonList = entries.map((e) => _habitEntryToMap(e)).toList();
    await prefs.setString(_entriesKey, jsonEncode(jsonList));
    return 1;
  }

  // Habit Names
  Future<int> insertHabitName(String name, int position) async {
    final names = await getAllHabitNames();
    if (!names.contains(name)) {
      names.add(name);
      await saveHabitNames(names);
    }
    return 1;
  }

  Future<List<String>> getAllHabitNames() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_namesKey);
    
    if (jsonStr == null) return [];
    
    final List<dynamic> jsonList = jsonDecode(jsonStr);
    return jsonList.map((e) => e.toString()).toList();
  }

  Future<void> saveHabitNames(List<String> names) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_namesKey, jsonEncode(names));
  }

  Future<int> deleteHabitName(String name) async {
    final names = await getAllHabitNames();
    names.remove(name);
    await saveHabitNames(names);
    return 1;
  }

  // Mapper
  Map<String, dynamic> _habitEntryToMap(HabitEntry entry) {
    return {
      'date': DateFormat('yyyy-MM-dd').format(entry.date),
      'drinkWater': entry.drinkWater,
      'eatHealthy': entry.eatHealthy,
      'exercise': entry.exercise,
      'journal': entry.journal,
      'month': entry.month,
      'noPornAlcohol': entry.noPornAlcohol,
      'planTomorrow': entry.planTomorrow,
      'progressBar': entry.progressBar,
      'read': entry.read,
      'sleep': entry.sleep,
      'socialMedia': entry.socialMedia,
      'study': entry.study,
      'dailyPercentage': entry.dailyPercentage,
      'notes': entry.notes,
    };
  }

  HabitEntry _mapToHabitEntry(Map<String, dynamic> map) {
    return HabitEntry(
      date: DateFormat('yyyy-MM-dd').parse(map['date']),
      drinkWater: map['drinkWater'] == true || map['drinkWater'] == 1,
      eatHealthy: map['eatHealthy'] == true || map['eatHealthy'] == 1,
      exercise: map['exercise'] == true || map['exercise'] == 1,
      journal: map['journal'] == true || map['journal'] == 1,
      month: map['month'],
      noPornAlcohol: map['noPornAlcohol'] == true || map['noPornAlcohol'] == 1,
      planTomorrow: map['planTomorrow'] == true || map['planTomorrow'] == 1,
      progressBar: map['progressBar'],
      read: map['read'] == true || map['read'] == 1,
      sleep: map['sleep'] == true || map['sleep'] == 1,
      socialMedia: map['socialMedia'] == true || map['socialMedia'] == 1,
      study: map['study'] == true || map['study'] == 1,
      dailyPercentage: map['dailyPercentage'],
      notes: map['notes'] ?? "",
    );
  }

  Future<void> close() async {
    // No-op for SharedPreferences
  }
}
