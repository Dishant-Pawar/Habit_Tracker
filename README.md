# Habit Tracker Dashboard - Flutter App

A beautiful and comprehensive Flutter dashboard for tracking your daily habits, visualizing progress, and maintaining motivation.

## Features

### 📊 Dashboard Overview
- **Quick Stats Cards**: Total days tracked, success rate, current streak, and best streak
- **Motivational Quote**: "Dishant Pawar" reminder
- **Monthly Progress Chart**: Visual bar chart showing monthly completion rates
- **Habit Completion Overview**: Percentage completion for each of your 10 habits

### 📝 Habit List View
- **Daily Breakdown**: Expandable cards showing each day's habit completion
- **Visual Indicators**: Green/Orange circles showing success (≥75% completion)
- **Detailed View**: Tap to see all 10 habits with check/cross marks
- **Date Navigation**: Browse through your habit history

### 📅 Calendar Heatmap
- **Monthly View**: Color-coded calendar showing daily performance
- **Color Legend**: 
  - Grey: No data (0%)
  - Red: 1-49% completion
  - Orange: 50-74% completion
  - Light Green: 75-99% completion
  - Green: 100% completion
- **Interactive**: Tap any day to see detailed stats
- **Month Navigation**: Browse through different months

### 📈 Detailed Statistics
- Total days tracked
- Successful days (≥75% completion)
- Average completion percentage
- Current and longest streaks
- Monthly breakdown with averages

## Your 10 Habits

1. 💤 Sleep 7-8 hours
2. 🥗 Eat healthy meals
3. 📱 Social media ≤ 90min
4. 🚫 No porn/alcohol
5. 💧 Drink 2L water
6. 💻 Study ≥ 2 hours
7. 🏋🏻‍♀️ Exercise 30 minutes
8. 📖 Read 30 minutes
9. 🖋️ Journal & self-reflect
10. 📋 Plan tomorrow's tasks

## Installation

### Prerequisites
- Flutter SDK (3.0.0 or higher)
- Android Studio / VS Code with Flutter extensions
- Android SDK / Xcode (for iOS)

### Steps

1. **Navigate to the project directory**:
   ```bash
   cd habit_tracker_dashboard
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run the app**:
   ```bash
   flutter run
   ```

## Loading Your Data

1. **Tap the upload icon** (📤) in the top right corner of the app
2. **Select your CSV file**: Navigate to your habit tracker CSV export
3. **View your data**: The dashboard will automatically load and display your habit data

### CSV Format
The app expects a CSV file with the following columns:
- Notes
- Date (format: "Month Day, Year", e.g., "January 25, 2025")
- Drink 2L water
- Eat healthy meals
- Exercise 30 minutes
- Journal & self-reflect
- Month
- No porn/alcohol
- Plan tomorrow's tasks
- Progress Bar
- Read 30 minutes
- Sleep 7-8 hours
- Social media ≤ 90min
- Study ≥ 2 hours
- daily percentage

## Project Structure

```
lib/
├── main.dart                      # App entry point
├── models/
│   └── habit_entry.dart          # Data models
├── services/
│   └── habit_data_service.dart   # CSV parsing and stats calculation
├── screens/
│   └── dashboard_screen.dart     # Main dashboard screen
└── widgets/
    ├── stats_card.dart           # Statistics card widget
    ├── habit_list_card.dart      # Habit list view
    ├── monthly_chart.dart        # Bar chart for monthly data
    └── habit_heatmap.dart        # Calendar heatmap view
```

## Customization

### Changing Theme Colors
Edit `main.dart` to customize the color scheme:
```dart
colorScheme: ColorScheme.fromSeed(
  seedColor: Colors.purple, // Change this color
  brightness: Brightness.light,
),
```

### Modifying Habits
Update the habit list in:
- `habit_data_service.dart` (habitCompletionCount map)
- `habit_list_card.dart` (_buildHabitRow calls)

## Dependencies

- **flutter**: SDK for building the app
- **fl_chart**: Beautiful charts and graphs
- **intl**: Date formatting
- **csv**: CSV file parsing
- **file_picker**: File selection dialog
- **shared_preferences**: Local data storage

## Building for Release

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

## Tips for Best Results

1. **Consistent Tracking**: Update your habits daily for accurate statistics
2. **Aim for 75%+**: Days with ≥75% completion are considered successful
3. **Track Streaks**: The app automatically calculates your current and best streaks
4. **Review Monthly**: Use the monthly chart to identify trends and patterns
5. **Export Regularly**: Keep your CSV data backed up

## Troubleshooting

### CSV Not Loading
- Ensure the CSV file follows the expected format
- Check that dates are in "Month Day, Year" format
- Verify that Yes/No values are spelled correctly

### App Crashes
- Run `flutter clean` then `flutter pub get`
- Check that all dependencies are installed
- Ensure you're using Flutter 3.0.0 or higher

## Future Enhancements

Potential features to add:
- [ ] Export data to CSV
- [ ] Add/edit habits directly in the app
- [ ] Push notifications for daily reminders
- [ ] Social sharing of achievements
- [ ] Habit recommendations based on performance
- [ ] Data synchronization across devices

## License

This project is open source and available for personal use.

## Credits

Created for tracking the "Dishant Pawar" habit system.

---

**Remember**: Dishant Pawar! 🌟
Keep building your habits, one day at a time! 💪
