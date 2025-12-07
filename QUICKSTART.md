# Quick Start Guide

## Running Your Habit Tracker Dashboard

### Option 1: Run on Windows Desktop
```powershell
cd habit_tracker_dashboard
flutter run -d windows
```

### Option 2: Run on Chrome (Web)
```powershell
cd habit_tracker_dashboard
flutter run -d chrome
```

### Option 3: Run on Android Emulator
1. Start your Android emulator
2. Run:
```powershell
cd habit_tracker_dashboard
flutter run
```

## How to Use the App

### Step 1: Load Your Data
1. Click the **upload icon** (📤) in the top-right corner
2. Select your `Habit Tracker 2bc561bfd0ff8178a043d0705460a7a3_all.csv` file
3. The app will automatically parse and display your data

### Step 2: Explore Your Dashboard
Navigate between 4 main screens using the bottom navigation bar:

#### 📊 Dashboard (Home)
- View your key stats: Total days, Success rate, Current streak, Best streak
- See monthly progress chart
- Check habit completion percentages

#### 📝 Habits (List View)
- Browse all your daily entries
- Expand any day to see detailed habit completion
- Green circle = successful day (≥75%)
- Orange circle = needs improvement

#### 📅 Calendar (Heatmap)
- Visual calendar with color-coded days
- Green = 100%, Light green = 75-99%, Orange = 50-74%, Red = 1-49%, Grey = no data
- Tap any day for detailed information
- Navigate between months using arrows

#### 📈 Stats (Detailed Statistics)
- Comprehensive breakdown of your tracking
- Monthly averages
- Streak information
- Success metrics

## Understanding Your Success

**A "successful day" = 75% or more habits completed**

To be considered a successful day, you need to complete at least **8 out of 10 habits**.

## Features

### 🔥 Streaks
The app tracks two types of streaks:
- **Current Streak**: Your ongoing streak of successful days
- **Longest Streak**: Your best ever streak

### 📊 Color Coding
Throughout the app, colors indicate performance:
- 🟢 **Green**: Excellent (75-100%)
- 🟠 **Orange**: Good (50-74%)
- 🔴 **Red**: Needs work (1-49%)
- ⚪ **Grey**: No data (0%)

### 📱 Responsive Design
- Works on mobile, tablet, and desktop
- Automatic light/dark theme based on system settings
- Touch-friendly interface

## Tips for Best Experience

1. **Keep your CSV updated** - Export from Notion regularly
2. **Review weekly** - Check your progress every Sunday
3. **Set goals** - Aim for at least 75% completion daily
4. **Track patterns** - Use the calendar view to spot trends
5. **Celebrate wins** - Check your streaks and monthly averages!

## Troubleshooting

### "No data loaded" message
- Make sure you've clicked the upload button
- Verify your CSV file is in the correct format
- Check that dates are formatted as "Month Day, Year"

### App won't start
```powershell
flutter clean
flutter pub get
flutter run
```

### CSV not recognized
Ensure your CSV has these exact columns:
- Notes, Date, Drink 2L water, Eat healthy meals, Exercise 30 minutes, Journal & self-reflect, Month, No porn/alcohol, Plan tomorrow's tasks, Ravan008isback, Read 30 minutes, Sleep 7-8 hours, Social media ≤ 90min, Study ≥ 2 hours, daily percentage

## Building for Production

### Android APK
```powershell
flutter build apk --release
```
Find your APK at: `build/app/outputs/flutter-apk/app-release.apk`

### Windows Desktop
```powershell
flutter build windows --release
```
Find your app at: `build/windows/runner/Release/`

### Web
```powershell
flutter build web --release
```
Find your web app at: `build/web/`

## Need Help?

Check the full README.md for detailed documentation and customization options.

---

**Remember**: Dishant! 🌟
