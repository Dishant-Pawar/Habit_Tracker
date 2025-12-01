import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/habit_entry.dart';
import 'package:intl/intl.dart';

class StorageService {
  static final StorageService instance = StorageService._init();
  
  StorageService._init();

  // Save all habit entries
  Future<void> saveHabitEntries(List<HabitEntry> entries) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Convert entries to JSON
      final List<Map<String, dynamic>> jsonList = entries.map((entry) {
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
      }).toList();
      
      // Save as JSON string
      final jsonString = jsonEncode(jsonList);
      print('💾 StorageService: Saving ${entries.length} entries (${jsonString.length} bytes)');
      final result = await prefs.setString('habit_entries', jsonString);
      print('💾 StorageService: Save result = $result');
      
      // Verify it was saved by reading it back immediately
      final verification = prefs.getString('habit_entries');
      print('✅ StorageService: Verification - stored data length = ${verification?.length ?? 0}');
    } catch (e) {
      print('❌ StorageService: Error saving entries: $e');
    }
  }

  // Load all habit entries
  Future<List<HabitEntry>> loadHabitEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString('habit_entries');
    
    print('📥 StorageService: Loading from storage...');
    print('📥 StorageService: Retrieved string = ${jsonString?.substring(0, jsonString != null && jsonString.length > 100 ? 100 : jsonString?.length ?? 0)}...');
    
    if (jsonString == null || jsonString.isEmpty) {
      print('📥 StorageService: No data found, returning empty list');
      return [];
    }
    
    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      print('📥 StorageService: Decoded ${jsonList.length} entries');
      
      return jsonList.map((json) {
        return HabitEntry(
          date: DateFormat('yyyy-MM-dd').parse(json['date']),
          drinkWater: json['drinkWater'] ?? false,
          eatHealthy: json['eatHealthy'] ?? false,
          exercise: json['exercise'] ?? false,
          journal: json['journal'] ?? false,
          month: json['month'] ?? '',
          noPornAlcohol: json['noPornAlcohol'] ?? false,
          planTomorrow: json['planTomorrow'] ?? false,
          progressBar: json['progressBar'] ?? '⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜ 0%',
          read: json['read'] ?? false,
          sleep: json['sleep'] ?? false,
          socialMedia: json['socialMedia'] ?? false,
          study: json['study'] ?? false,
          dailyPercentage: json['dailyPercentage'] ?? 0,
          notes: json['notes'] ?? '',
        );
      }).toList();
    } catch (e) {
      print('❌ StorageService: Error loading habit entries: $e');
      return [];
    }
  }

  // Save habit names
  Future<void> saveHabitNames(List<String> names) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('habit_names', names);
  }

  // Load habit names
  Future<List<String>> loadHabitNames() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('habit_names') ?? [];
  }
}
