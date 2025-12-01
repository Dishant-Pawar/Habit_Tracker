class HabitEntry {
  final DateTime date;
  bool drinkWater;
  bool eatHealthy;
  bool exercise;
  bool journal;
  final String month;
  bool noPornAlcohol;
  bool planTomorrow;
  String progressBar;
  bool read;
  bool sleep;
  bool socialMedia;
  bool study;
  int dailyPercentage;
  final String notes;

  HabitEntry({
    required this.date,
    required this.drinkWater,
    required this.eatHealthy,
    required this.exercise,
    required this.journal,
    required this.month,
    required this.noPornAlcohol,
    required this.planTomorrow,
    required this.progressBar,
    required this.read,
    required this.sleep,
    required this.socialMedia,
    required this.study,
    required this.dailyPercentage,
    required this.notes,
  });

  int get completedHabits {
    int count = 0;
    if (drinkWater) count++;
    if (eatHealthy) count++;
    if (exercise) count++;
    if (journal) count++;
    if (noPornAlcohol) count++;
    if (planTomorrow) count++;
    if (read) count++;
    if (sleep) count++;
    if (socialMedia) count++;
    if (study) count++;
    return count;
  }

  bool get isSuccessfulDay => dailyPercentage >= 75;
}

class HabitStats {
  final int totalDays;
  final int successfulDays;
  final double averageCompletion;
  final int currentStreak;
  final int longestStreak;
  final Map<String, int> habitCompletionCount;

  HabitStats({
    required this.totalDays,
    required this.successfulDays,
    required this.averageCompletion,
    required this.currentStreak,
    required this.longestStreak,
    required this.habitCompletionCount,
  });

  double get successRate => totalDays > 0 ? (successfulDays / totalDays) * 100 : 0;
}

class MonthlyOverview {
  final String name;
  final double monthlyAverage;
  final String progressBar;
  final int daysTracked;

  MonthlyOverview({
    required this.name,
    required this.monthlyAverage,
    required this.progressBar,
    required this.daysTracked,
  });
}
