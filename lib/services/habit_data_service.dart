import 'package:csv/csv.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import '../models/habit_entry.dart';

class HabitDataService {
  static Future<List<HabitEntry>> loadFromCSV(List<int> bytes) async {
    final csvString = utf8.decode(bytes);
    
    List<List<dynamic>> rowsAsListOfValues = const CsvToListConverter().convert(csvString);
    
    // Skip header row
    if (rowsAsListOfValues.isEmpty) return [];
    
    List<HabitEntry> entries = [];
    
    for (int i = 1; i < rowsAsListOfValues.length; i++) {
      try {
        final row = rowsAsListOfValues[i];
        if (row.length < 15) continue;
        
        // Parse date
        DateTime? date;
        try {
          date = DateFormat('MMMM d, yyyy').parse(row[1].toString());
        } catch (e) {
          continue;
        }
        
        final entry = HabitEntry(
          date: date,
          drinkWater: row[2].toString().toLowerCase() == 'yes',
          eatHealthy: row[3].toString().toLowerCase() == 'yes',
          exercise: row[4].toString().toLowerCase() == 'yes',
          journal: row[5].toString().toLowerCase() == 'yes',
          month: row[6].toString(),
          noPornAlcohol: row[7].toString().toLowerCase() == 'yes',
          planTomorrow: row[8].toString().toLowerCase() == 'yes',
          progressBar: row[9].toString(),
          read: row[10].toString().toLowerCase() == 'yes',
          sleep: row[11].toString().toLowerCase() == 'yes',
          socialMedia: row[12].toString().toLowerCase() == 'yes',
          study: row[13].toString().toLowerCase() == 'yes',
          dailyPercentage: int.tryParse(row[14].toString()) ?? 0,
          notes: row[0].toString(),
        );
        
        entries.add(entry);
      } catch (e) {
        continue;
      }
    }
    
    return entries;
  }

  static HabitStats calculateStats(List<HabitEntry> entries) {
    if (entries.isEmpty) {
      return HabitStats(
        totalDays: 0,
        successfulDays: 0,
        averageCompletion: 0,
        currentStreak: 0,
        longestStreak: 0,
        habitCompletionCount: {},
      );
    }

    // Sort entries by date
    entries.sort((a, b) => a.date.compareTo(b.date));

    int totalDays = entries.length;
    int successfulDays = entries.where((e) => e.isSuccessfulDay).length;
    double averageCompletion = entries.map((e) => e.dailyPercentage).reduce((a, b) => a + b) / totalDays;

    // Calculate streaks
    int currentStreak = 0;
    int longestStreak = 0;
    int tempStreak = 0;

    for (int i = entries.length - 1; i >= 0; i--) {
      if (entries[i].isSuccessfulDay) {
        tempStreak++;
        if (i == entries.length - 1 || currentStreak == 0) {
          currentStreak = tempStreak;
        }
        if (tempStreak > longestStreak) {
          longestStreak = tempStreak;
        }
      } else {
        if (i == entries.length - 1) {
          currentStreak = 0;
        }
        tempStreak = 0;
      }
    }

    // Count habit completions
    Map<String, int> habitCompletionCount = {
      'Sleep 7-8 hours 💤': entries.where((e) => e.sleep).length,
      'Eat healthy meals 🥗': entries.where((e) => e.eatHealthy).length,
      'Social media ≤ 90min 📱': entries.where((e) => e.socialMedia).length,
      'No porn/alcohol 🚫': entries.where((e) => e.noPornAlcohol).length,
      'Drink 2L water 💧': entries.where((e) => e.drinkWater).length,
      'Study ≥ 2 hours 💻': entries.where((e) => e.study).length,
      'Exercise 30 minutes 🏋🏻‍♀️': entries.where((e) => e.exercise).length,
      'Read 30 minutes 📖': entries.where((e) => e.read).length,
      'Journal & self-reflect 🖋️': entries.where((e) => e.journal).length,
      'Plan tomorrow\'s tasks 📋': entries.where((e) => e.planTomorrow).length,
    };

    return HabitStats(
      totalDays: totalDays,
      successfulDays: successfulDays,
      averageCompletion: averageCompletion,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      habitCompletionCount: habitCompletionCount,
    );
  }

  static List<MonthlyOverview> getMonthlyOverview(List<HabitEntry> entries) {
    Map<String, List<HabitEntry>> monthGroups = {};
    
    for (var entry in entries) {
      String monthKey = DateFormat('MMMM yyyy').format(entry.date);
      if (!monthGroups.containsKey(monthKey)) {
        monthGroups[monthKey] = [];
      }
      monthGroups[monthKey]!.add(entry);
    }

    return monthGroups.entries.map((e) {
      double avg = e.value.map((entry) => entry.dailyPercentage).reduce((a, b) => a + b) / e.value.length;
      int filled = (avg / 10).round();
      String progressBar = '⬛' * filled + '⬜' * (10 - filled) + ' ${avg.round()}%';
      
      return MonthlyOverview(
        name: e.key,
        monthlyAverage: avg,
        progressBar: progressBar,
        daysTracked: e.value.length,
      );
    }).toList();
  }
}
