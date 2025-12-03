import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../models/habit_entry.dart';
import '../services/habit_data_service.dart';
import '../widgets/stats_card.dart';
import '../widgets/habit_list_card.dart';
import '../widgets/monthly_chart.dart';
import '../widgets/habit_heatmap.dart';
import '../main.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<HabitEntry> _entries = [];
  HabitStats? _stats;
  List<MonthlyOverview> _monthlyOverview = [];
  bool _isLoading = false;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadSampleData();
  }

  Future<void> _loadSampleData() async {
    // Load with sample data or allow user to load CSV
  }

  Future<void> _loadCSVData() async {
    setState(() => _isLoading = true);
    
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        withData: true, // Important for web platform
      );

      if (result != null && result.files.single.bytes != null) {
        final entries = await HabitDataService.loadFromCSV(result.files.single.bytes!);
        final stats = HabitDataService.calculateStats(entries);
        final monthly = HabitDataService.getMonthlyOverview(entries);

        setState(() {
          _entries = entries;
          _stats = stats;
          _monthlyOverview = monthly;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading CSV: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Habit Tracker Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            onPressed: _loadCSVData,
            tooltip: 'Load CSV Data',
          ),
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () {
              HabitTrackerApp.of(context)?.toggleTheme();
            },
            tooltip: 'Toggle Dark Mode',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _selectedIndex == 0
              ? _buildDashboard()
              : _selectedIndex == 1
                  ? _buildHabitList()
                  : _selectedIndex == 2
                      ? _buildCalendarView()
                      : _buildStatsView(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.list),
            label: 'Habits',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month),
            label: 'Calendar',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart),
            label: 'Stats',
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    if (_stats == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.upload_file, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No data loaded',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _loadCSVData,
              icon: const Icon(Icons.upload),
              label: const Text('Load CSV File'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Motivational Quote
          Column(
            children: [
              Text(
                '🌟 DP THE SILENT KILLER',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: const Color(0xFF00FF41),
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: const Color(0xFF00FF41).withOpacity(0.8),
                          blurRadius: 10,
                        ),
                      ],
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Keep building your habits, one day at a time!',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Stats Grid
          Row(
            children: [
              Expanded(
                child: StatsCard(
                  title: 'Total Days',
                  value: _stats!.totalDays.toString(),
                  icon: Icons.calendar_today,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatsCard(
                  title: 'Success Rate',
                  value: '${_stats!.successRate.toStringAsFixed(1)}%',
                  icon: Icons.check_circle,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: StatsCard(
                  title: 'Current Streak',
                  value: '${_stats!.currentStreak} 🔥',
                  icon: Icons.local_fire_department,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatsCard(
                  title: 'Best Streak',
                  value: _stats!.longestStreak.toString(),
                  icon: Icons.star,
                  color: Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Monthly Progress Chart
          Text(
            'Monthly Progress',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          MonthlyChart(monthlyData: _monthlyOverview),
          const SizedBox(height: 24),

          // Habit Completion Overview
          Text(
            'Habit Completion Overview',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: _stats!.habitCompletionCount.entries.map((entry) {
                  double percentage = (_stats!.totalDays > 0)
                      ? (entry.value / _stats!.totalDays) * 100
                      : 0;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                entry.key,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                            Text(
                              '${percentage.toStringAsFixed(1)}%',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: percentage / 100,
                          backgroundColor: Colors.grey[300],
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitList() {
    if (_entries.isEmpty) {
      return const Center(child: Text('No habit data available'));
    }

    return HabitListCard(entries: _entries);
  }

  Widget _buildCalendarView() {
    if (_entries.isEmpty) {
      return const Center(child: Text('No habit data available'));
    }

    return HabitHeatmap(entries: _entries);
  }

  Widget _buildStatsView() {
    if (_stats == null) {
      return const Center(child: Text('No statistics available'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detailed Statistics',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatRow('Total Days Tracked', _stats!.totalDays.toString()),
                  const Divider(),
                  _buildStatRow('Successful Days (≥75%)', _stats!.successfulDays.toString()),
                  const Divider(),
                  _buildStatRow('Average Completion', '${_stats!.averageCompletion.toStringAsFixed(1)}%'),
                  const Divider(),
                  _buildStatRow('Current Streak', '${_stats!.currentStreak} days 🔥'),
                  const Divider(),
                  _buildStatRow('Longest Streak', '${_stats!.longestStreak} days ⭐'),
                  const Divider(),
                  _buildStatRow('Success Rate', '${_stats!.successRate.toStringAsFixed(1)}%'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          Text(
            'Monthly Breakdown',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          
          ..._monthlyOverview.map((month) => Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(month.name),
                  subtitle: Text('${month.daysTracked} days tracked'),
                  trailing: Text(
                    '${month.monthlyAverage.toStringAsFixed(1)}%',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
