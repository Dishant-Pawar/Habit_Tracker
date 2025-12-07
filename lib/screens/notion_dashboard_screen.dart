import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import '../models/habit_entry.dart';
import '../services/habit_data_service.dart';
import '../services/storage_service.dart';
import '../utils/responsive_helper.dart';
import '../main.dart';

class NotionDashboardScreen extends StatefulWidget {
  const NotionDashboardScreen({super.key});

  @override
  State<NotionDashboardScreen> createState() => _NotionDashboardScreenState();
}

class _NotionDashboardScreenState extends State<NotionDashboardScreen> {
  List<HabitEntry> _entries = [];
  bool _isLoading = false;
  String _selectedView = 'This Week';
  String _previousView = 'This Week';
  DateTime _selectedMonth = DateTime.now();
  bool _isSidebarOpen = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _horizontalScrollController = ScrollController();
  // This is the sidebar screen this is used for the sidebar menu
  List<String> habitNames = [
    'Sleep 7-8 hours 💤',
    'Eat healthy meals 🥗',
    'Social media ≤ 90min 📱',
    'NO Smoke 🚫',
    'Drink 2L water 💧',
    'Study ≥ 2 hours 💻',
    'Exercise 30 minutes 🏋🏻‍♀️',
    'Read 30 minutes 📖',
    'Journal & self-reflect 🖋️',
    'Plan tomorrow\'s tasks 📋',
  ];

  @override
  void initState() {
    super.initState();
    _loadFromStorage();
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    super.dispose();
  }

  Future<void> _loadFromStorage() async {
    setState(() => _isLoading = true);
    try {
      // Load habit entries from storage
      final entries = await StorageService.instance.loadHabitEntries();
      print('📥 Loaded ${entries.length} entries from storage');
      for (var entry in entries) {
        print('  - ${DateFormat('yyyy-MM-dd').format(entry.date)}: ${entry.dailyPercentage}%');
      }
      
      // Load habit names from storage
      final savedHabitNames = await StorageService.instance.loadHabitNames();
      
      setState(() {
        _entries = entries;
        if (savedHabitNames.isNotEmpty) {
          habitNames.clear();
          habitNames.addAll(savedHabitNames);
        } else {
          // Save default habit names on first run
          StorageService.instance.saveHabitNames(habitNames);
        }
      });
    } catch (e) {
      print('Error loading from storage: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final responsive = ResponsiveHelper(context, constraints);
        
        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          drawer: responsive.isSmall ? Drawer(
            child: _buildSidebar(responsive),
          ) : null,
          body: SafeArea(
            child: Row(
              children: [
                // Left Sidebar (only on desktop/tablet)
                if (!responsive.isSmall)
                  SizedBox(
                    width: _isSidebarOpen ? responsive.sidebarWidth : 0,
                    child: _isSidebarOpen ? _buildSidebar(responsive) : const SizedBox(),
                  ),
                // Main Content
                Expanded(
                  child: Column(
                    children: [
                      _buildTopBar(responsive),
                      Expanded(
                        child: _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : _buildMainContent(responsive),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSidebar(ResponsiveHelper responsive) {
    return Container(
      width: responsive.sidebarWidth,
      color: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF1A1A1A)
          : const Color(0xFFFBFAF8),
      padding: responsive.padding(const EdgeInsets.all(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'HABIT TRACKER',
            style: TextStyle(
              fontSize: responsive.fontSize(24),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: responsive.spacing(32)),
          Text(
            'Rise stronger every day',
            style: TextStyle(
              fontSize: responsive.fontSize(14),
              fontWeight: FontWeight.bold,
              color: const Color(0xFF00FF41),
              shadows: [
                Shadow(
                  color: const Color(0xFF00FF41).withOpacity(0.8),
                  blurRadius: 10,
                ),
              ],
            ),
          ),
          SizedBox(height: responsive.spacing(24)),
          Row(
            children: [
              Flexible(
                child: Text(
                  '📋 Habit List',
                  style: TextStyle(
                    fontSize: responsive.fontSize(16),
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF64B5F6)
                        : null,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(Icons.add, size: responsive.mediumIconSize),
                onPressed: _addNewHabit,
                tooltip: 'Add Habit',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          SizedBox(height: responsive.spacing(16)),
          Expanded(
            child: ListView.builder(
              itemCount: habitNames.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(
                    left: responsive.spacing(24),
                    bottom: responsive.spacing(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '• ${habitNames[index]}',
                          style: TextStyle(
                            fontSize: responsive.fontSize(14),
                            color: Theme.of(context).brightness == Brightness.dark
                                ? const Color(0xFF64B5F6)
                                : null,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                      SizedBox(width: responsive.spacing(4)),
                      IconButton(
                        icon: Icon(Icons.edit, size: responsive.smallIconSize),
                        onPressed: () => _editHabit(index),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        tooltip: 'Edit',
                      ),
                      SizedBox(width: responsive.spacing(4)),
                      IconButton(
                        icon: Icon(Icons.delete, size: responsive.smallIconSize),
                        onPressed: () => _deleteHabit(index),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        tooltip: 'Delete',
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          SizedBox(height: responsive.spacing(24)),
          _buildSidebarMonthlyChart(responsive),
        ],
      ),
    );
  }

  Widget _buildSidebarMonthlyChart(ResponsiveHelper responsive) {
    // Get current month's data
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
    
    // Calculate monthly statistics
    Map<String, int> monthlyHabitStats = {};
    int totalDaysInMonth = lastDayOfMonth.day;
    
    for (int i = 0; i < habitNames.length && i < 10; i++) {
      int completed = 0;
      for (int day = 1; day <= totalDaysInMonth; day++) {
        final date = DateTime(now.year, now.month, day);
        final entry = _entries.firstWhere(
          (e) => e.date.year == date.year && e.date.month == date.month && e.date.day == date.day,
          orElse: () => HabitEntry(
            date: date,
            drinkWater: false,
            eatHealthy: false,
            exercise: false,
            journal: false,
            month: '',
            noPornAlcohol: false,
            planTomorrow: false,
            progressBar: '',
            read: false,
            sleep: false,
            socialMedia: false,
            study: false,
            dailyPercentage: 0,
            notes: '',
          ),
        );
        if (_getHabitValueByIndex(entry, i)) {
          completed++;
        }
      }
      int percentage = ((completed / totalDaysInMonth) * 100).round();
      monthlyHabitStats[habitNames[i]] = percentage;
    }

    // Get top 5 habits for pie chart
    var sortedHabits = monthlyHabitStats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    var topHabits = sortedHabits.take(5).toList();
    
    int total = topHabits.fold(0, (sum, entry) => sum + entry.value);
    
    List<Color> colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
    ];

    return Container(
      padding: responsive.padding(const EdgeInsets.all(16)),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF2D2D2D)
            : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF404040)
              : const Color(0xFFE5E5E5),
        ),
      ),
      child: Column(
        children: [
          Text(
            '📊 ${DateFormat('MMMM yyyy').format(now)}',
            style: TextStyle(
              fontSize: responsive.fontSize(14),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: responsive.spacing(12)),
          SizedBox(
            width: 150,
            height: 150,
            child: CustomPaint(
              size: const Size(150, 150),
              painter: _PieChartPainter(topHabits, colors, total),
            ),
          ),
          SizedBox(height: responsive.spacing(8)),
          ...topHabits.asMap().entries.map((item) {
            int index = item.key;
            var entry = item.value;
            double percentage = total > 0 ? (entry.value / total * 100) : 0;
            
            return Padding(
              padding: EdgeInsets.only(bottom: responsive.spacing(2)),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: colors[index],
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: responsive.spacing(6)),
                  Expanded(
                    child: Text(
                      entry.key,
                      style: TextStyle(fontSize: responsive.fontSize(10)),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${percentage.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: responsive.fontSize(10),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTopBar(ResponsiveHelper responsive) {
    return Container(
      height: responsive.topBarHeight,
      padding: responsive.padding(EdgeInsets.symmetric(horizontal: responsive.isSmall ? 8 : 24)),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1A1A1A)
            : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF2D2D2D)
                : const Color(0xFFE5E5E5),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              responsive.isSmall
                  ? Icons.menu
                  : (_isSidebarOpen ? Icons.menu_open : Icons.menu),
              size: responsive.largeIconSize,
            ),
            onPressed: () {
              if (responsive.isSmall) {
                _scaffoldKey.currentState?.openDrawer();
              } else {
                setState(() {
                  _isSidebarOpen = !_isSidebarOpen;
                });
              }
            },
            tooltip: responsive.isSmall
                ? 'Open Menu'
                : (_isSidebarOpen ? 'Close Sidebar' : 'Open Sidebar'),
          ),
          if (!responsive.isSmall) SizedBox(width: responsive.spacing(16)),
          if (!responsive.isSmall) ...[
            _buildViewButton(responsive, '📅 This Week', 'This Week'),
            SizedBox(width: responsive.spacing(8)),
            _buildViewButton(responsive, '📆 This Month', 'This Month'),
            SizedBox(width: responsive.spacing(8)),
            _buildViewButton(responsive, '📊 Monthly Overview', 'Monthly Overview'),
          ],
          if (responsive.isSmall) ...[
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: responsive.padding(const EdgeInsets.symmetric(horizontal: 4)),
                child: Row(
                  children: [
                    _buildViewButton(responsive, '📅', 'This Week'),
                    SizedBox(width: responsive.spacing(4)),
                    _buildViewButton(responsive, '📆', 'This Month'),
                    SizedBox(width: responsive.spacing(4)),
                    _buildViewButton(responsive, '📊', 'Monthly Overview'),
                  ],
                ),
              ),
            ),
          ],
          if (responsive.isSmall) SizedBox(width: responsive.spacing(4)),
          IconButton(
            icon: Icon(Icons.add_circle_outline, size: responsive.largeIconSize),
            onPressed: _addNewDay,
            tooltip: 'Add New Day',
          ),
          const Spacer(),
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
              size: responsive.largeIconSize,
            ),
            onPressed: () {
              HabitTrackerApp.of(context)?.toggleTheme();
            },
            tooltip: 'Toggle Dark Mode',
          ),
        ],
      ),
    );
  }

  Widget _buildViewButton(ResponsiveHelper responsive, String label, String view) {
    final bool isSelected = _selectedView == view;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return InkWell(
      onTap: () {
        if (_selectedView != view) {
          setState(() {
            _previousView = _selectedView;
            _selectedView = view;
          });
          // Reset scroll position when view changes
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_horizontalScrollController.hasClients) {
              _horizontalScrollController.jumpTo(0);
            }
          });
        }
      },
      child: Container(
        padding: responsive.padding(
          EdgeInsets.symmetric(
            horizontal: responsive.isSmall ? 8 : 16,
            vertical: 8,
          ),
        ),
        decoration: BoxDecoration(
          color: isSelected 
              ? (isDark ? const Color(0xFF2D2D2D) : const Color(0xFFE8E6E3))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: responsive.fontSize(responsive.isSmall ? 12 : 14),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isDark ? const Color(0xFF64B5F6) : null,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildMainContent(ResponsiveHelper responsive) {
    switch (_selectedView) {
      case 'This Week':
        return _buildThisWeekView(responsive);
      case 'This Month':
        return _buildThisMonthView(responsive);
      case 'Monthly Overview':
        return _buildMonthlyOverviewView(responsive);
      default:
        return _buildThisWeekView(responsive);
    }
  }

  Widget _buildThisWeekView(ResponsiveHelper responsive) {
    final now = DateTime.now();
    // Get Monday of current week (weekday 1 = Monday, 7 = Sunday)
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    // Get Sunday of current week
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    
    // Create list with all 7 days of the week
    List<HabitEntry> weekEntries = [];
    for (int i = 0; i < 7; i++) {
      final date = startOfWeek.add(Duration(days: i));
      // Find existing entry for this date
      final existingEntry = _entries.firstWhere(
        (entry) => entry.date.year == date.year && 
                   entry.date.month == date.month && 
                   entry.date.day == date.day,
        orElse: () => HabitEntry(
          date: date,
          drinkWater: false,
          eatHealthy: false,
          exercise: false,
          journal: false,
          month: DateFormat('MMMM').format(date),
          noPornAlcohol: false,
          planTomorrow: false,
          progressBar: '⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜ 0%',
          read: false,
          sleep: false,
          socialMedia: false,
          study: false,
          dailyPercentage: 0,
          notes: '',
        ),
      );
      weekEntries.add(existingEntry);
    }

    return SingleChildScrollView(
      padding: responsive.padding(const EdgeInsets.all(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_today, size: responsive.mediumIconSize),
              SizedBox(width: responsive.spacing(8)),
              Expanded(
                child: Text(
                  responsive.isMobile 
                    ? 'This Week\n${DateFormat('MMM d').format(startOfWeek)} - ${DateFormat('MMM d').format(endOfWeek)}'
                    : 'This Week (${DateFormat('MMM d').format(startOfWeek)} - ${DateFormat('MMM d, yyyy').format(endOfWeek)})',
                  style: TextStyle(
                    fontSize: responsive.fontSize(20),
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: responsive.isMobile ? 2 : 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: responsive.spacing(24)),
          _buildHabitStatistics(responsive, weekEntries),
          SizedBox(height: responsive.spacing(24)),
          _buildTableView(responsive, weekEntries),
        ],
      ),
    );
  }

  Widget _buildThisMonthView(ResponsiveHelper responsive) {
    // Get all days in the selected month
    final firstDayOfMonth = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final lastDayOfMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;
    
    // Create entries for all days in the month
    List<HabitEntry> monthEntries = [];
    for (int i = 1; i <= daysInMonth; i++) {
      final date = DateTime(_selectedMonth.year, _selectedMonth.month, i);
      // Find existing entry for this date
      final existingEntry = _entries.firstWhere(
        (entry) => entry.date.year == date.year && 
                   entry.date.month == date.month && 
                   entry.date.day == date.day,
        orElse: () => HabitEntry(
          date: date,
          drinkWater: false,
          eatHealthy: false,
          exercise: false,
          journal: false,
          month: DateFormat('MMMM').format(date),
          noPornAlcohol: false,
          planTomorrow: false,
          progressBar: '⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜ 0%',
          read: false,
          sleep: false,
          socialMedia: false,
          study: false,
          dailyPercentage: 0,
          notes: '',
        ),
      );
      monthEntries.add(existingEntry);
    }

    return SingleChildScrollView(
      padding: responsive.padding(const EdgeInsets.all(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: responsive.spacing(8),
            runSpacing: responsive.spacing(8),
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Icon(Icons.calendar_month, size: responsive.mediumIconSize),
              Text(
                DateFormat('MMMM yyyy').format(_selectedMonth),
                style: TextStyle(
                  fontSize: responsive.fontSize(20),
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: Icon(Icons.chevron_left, size: responsive.largeIconSize),
                onPressed: () {
                  setState(() {
                    _selectedMonth = DateTime(
                      _selectedMonth.year,
                      _selectedMonth.month - 1,
                    );
                  });
                },
                tooltip: 'Previous Month',
              ),
              IconButton(
                icon: Icon(Icons.chevron_right, size: responsive.largeIconSize),
                onPressed: () {
                  setState(() {
                    _selectedMonth = DateTime(
                      _selectedMonth.year,
                      _selectedMonth.month + 1,
                    );
                  });
                },
                tooltip: 'Next Month',
              ),
              TextButton.icon(
                icon: Icon(Icons.today, size: responsive.smallIconSize),
                label: Text(
                  'Today',
                  style: TextStyle(fontSize: responsive.fontSize(14)),
                ),
                onPressed: () {
                  setState(() {
                    _selectedMonth = DateTime.now();
                  });
                },
              ),
            ],
          ),
          SizedBox(height: responsive.spacing(16)),
          _buildTableView(responsive, monthEntries),
        ],
      ),
    );
  }

  Widget _buildTableView(ResponsiveHelper responsive, List<HabitEntry> entries) {
    return Card(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Scrollbar(
            controller: _horizontalScrollController,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: _horizontalScrollController,
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: constraints.maxWidth,
                ),
                child: DataTable(
                headingRowColor: WidgetStateProperty.all(
                  Theme.of(context).brightness == Brightness.dark
                      ? const Color.fromARGB(255, 172, 244, 84)
                      : const Color.fromARGB(0, 249, 249, 249),
                ),
                headingRowHeight: responsive.tableRowHeight,
                columnSpacing: responsive.value<double>(
                  mobile: 8,
                  tablet: 10,
                  desktop: 12,
                  largeDesktop: 14,
                ),
                horizontalMargin: responsive.value<double>(
                  mobile: 12,
                  tablet: 16,
                  desktop: 20,
                  largeDesktop: 24,
                ),
                dataRowHeight: responsive.value<double>(
                  mobile: 48,
                  tablet: 52,
                  desktop: 56,
                  largeDesktop: 60,
                ),
          columns: [
            DataColumn(
              label: Text(
                '📅\nDate',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: responsive.fontSize(13),
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            DataColumn(
              label: Text(
                'Progress',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: responsive.fontSize(13),
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            ...List.generate(
              habitNames.length,
              (index) => DataColumn(
                label: InkWell(
                  onTap: () => _editColumnHeader(index),
                  child: Text(
                    habitNames[index],
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: responsive.fontSize(13),
                      color: Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ),
            ),
          ],
          rows: entries.map((entry) {
            return DataRow(
              cells: [
                DataCell(
                  Text(
                    responsive.isMobile 
                      ? '${DateFormat('E').format(entry.date).toUpperCase().padRight(0)}, ${DateFormat('MMMM').format(entry.date).padRight(9)} ${entry.date.day.toString().padLeft(2)}, ${entry.date.year}'
                      : '${DateFormat('E').format(entry.date).toUpperCase().padRight(0)}, ${DateFormat('MMMM').format(entry.date).padRight(9)} ${entry.date.day.toString().padLeft(2)}, ${entry.date.year}',
                    style: TextStyle(
                      fontSize: responsive.fontSize(14),
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF64B5F6)
                          : null,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                DataCell(_buildProgressBar(responsive, entry.dailyPercentage)),
                ...List.generate(
                  habitNames.length,
                  (index) => DataCell(_buildDynamicCheckbox(responsive, entry, index)),
                ),
              ],
            );
          }).toList(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProgressBar(ResponsiveHelper responsive, int percentage) {
    int filledBlocks = (percentage / 10).floor();
    
    // Determine color based on percentage
    Color getBlockColor() {
      if (percentage < 50) {
        return Colors.red;
      } else if (percentage < 80) {
        return Colors.yellow;
      } else {
        return Colors.green;
      }
    }
    
    // Use very small sizes to fit in tight table cells
    final blockSize = responsive.value<double>(
      mobile: 4,
      tablet: 5,
      desktop: 7,
      largeDesktop: 9,
    );
    
    final blockSpacing = responsive.value<double>(
      mobile: 0.5,
      tablet: 0.8,
      desktop: 1,
      largeDesktop: 1.5,
    );
    
    if (responsive.isMobile) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              10,
              (index) => Container(
                width: blockSize,
                height: blockSize,
                margin: EdgeInsets.only(right: index < 9 ? blockSpacing : 0),
                decoration: BoxDecoration(
                  color: index < filledBlocks 
                      ? getBlockColor()
                      : const Color(0xFFE5E5E5),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ),
          ),
          SizedBox(height: responsive.spacing(2)),
          Text(
            '$percentage%',
            style: TextStyle(
              fontSize: responsive.fontSize(7),
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF64B5F6)
                  : null,
            ),
          ),
        ],
      );
    }
    
    // Desktop: Fit blocks and percentage in available space
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            10,
            (index) => Container(
              width: blockSize,
              height: blockSize,
              margin: EdgeInsets.only(right: index < 9 ? blockSpacing : 0),
              decoration: BoxDecoration(
                color: index < filledBlocks 
                    ? getBlockColor()
                    : const Color(0xFFE5E5E5),
                borderRadius: BorderRadius.circular(1.5),
              ),
            ),
          ),
        ),
        SizedBox(height: responsive.spacing(2)),
        Text(
          '$percentage%',
          style: TextStyle(
            fontSize: responsive.fontSize(8),
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF64B5F6)
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildCheckbox(ResponsiveHelper responsive, bool checked) {
    final size = responsive.checkboxSize;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: checked ? Colors.blue : Colors.transparent,
        border: Border.all(
          color: checked ? Colors.blue : const Color(0xFFD1D5DB),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: checked
          ? Icon(
              Icons.check,
              size: size * 0.65,
              color: Colors.white,
            )
          : null,
    );
  }

  Widget _buildDynamicCheckbox(ResponsiveHelper responsive, HabitEntry entry, int habitIndex) {
    // Map habit index to the corresponding field (for the first 10 default habits)
    final habitFields = ['sleep', 'eatHealthy', 'socialMedia', 'noPornAlcohol', 
                        'drinkWater', 'study', 'exercise', 'read', 'journal', 'planTomorrow'];
    
    bool checked = false;
    if (habitIndex < habitFields.length) {
      checked = _getHabitValue(entry, habitFields[habitIndex]);
    }
    
    final size = responsive.checkboxSize;
    
    return InkWell(
      onTap: () async {
        if (habitIndex < habitFields.length) {
          _toggleHabitValue(entry, habitFields[habitIndex]);
          
          // Recalculate percentage
          entry.dailyPercentage = _calculateDailyPercentage(entry);
          
          // Find if this entry exists in the database
          final existingIndex = _entries.indexWhere((e) => 
            e.date.year == entry.date.year && 
            e.date.month == entry.date.month && 
            e.date.day == entry.date.day
          );
          
          // Check if any habit is checked for this day
          final hasAnyChecked = _hasAnyHabitChecked(entry);
          
          if (hasAnyChecked) {
            // If any habit is checked, save/update the entry
            setState(() {
              if (existingIndex == -1) {
                _entries.add(entry);
                _entries.sort((a, b) => b.date.compareTo(a.date));
              } else {
                _entries[existingIndex] = entry;
              }
            });
            // Save to database
            await StorageService.instance.saveHabitEntries(_entries);
          } else {
            // If all habits are unchecked, remove the entry from database
            if (existingIndex != -1) {
              setState(() {
                _entries.removeAt(existingIndex);
              });
              await StorageService.instance.saveHabitEntries(_entries);
            }
          }
          
          // Reload entries from storage to ensure consistency
          final reloadedEntries = await StorageService.instance.loadHabitEntries();
          setState(() {
            _entries = reloadedEntries;
          });
        }
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: checked ? Colors.blue : Colors.transparent,
          border: Border.all(
            color: checked ? Colors.blue : const Color(0xFFD1D5DB),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: checked
            ? Icon(
                Icons.check,
                size: size * 0.65,
                color: Colors.white,
              )
            : null,
      ),
    );
  }

  bool _getHabitValue(HabitEntry entry, String habitField) {
    switch (habitField) {
      case 'sleep': return entry.sleep;
      case 'eatHealthy': return entry.eatHealthy;
      case 'socialMedia': return entry.socialMedia;
      case 'noPornAlcohol': return entry.noPornAlcohol;
      case 'drinkWater': return entry.drinkWater;
      case 'study': return entry.study;
      case 'exercise': return entry.exercise;
      case 'read': return entry.read;
      case 'journal': return entry.journal;
      case 'planTomorrow': return entry.planTomorrow;
      default: return false;
    }
  }

  void _toggleHabitValue(HabitEntry entry, String habitField) {
    switch (habitField) {
      case 'sleep': entry.sleep = !entry.sleep; break;
      case 'eatHealthy': entry.eatHealthy = !entry.eatHealthy; break;
      case 'socialMedia': entry.socialMedia = !entry.socialMedia; break;
      case 'noPornAlcohol': entry.noPornAlcohol = !entry.noPornAlcohol; break;
      case 'drinkWater': entry.drinkWater = !entry.drinkWater; break;
      case 'study': entry.study = !entry.study; break;
      case 'exercise': entry.exercise = !entry.exercise; break;
      case 'read': entry.read = !entry.read; break;
      case 'journal': entry.journal = !entry.journal; break;
      case 'planTomorrow': entry.planTomorrow = !entry.planTomorrow; break;
    }
  }

  bool _hasAnyHabitChecked(HabitEntry entry) {
    return entry.sleep || entry.eatHealthy || entry.socialMedia || 
           entry.noPornAlcohol || entry.drinkWater || entry.study || 
           entry.exercise || entry.read || entry.journal || entry.planTomorrow;
  }

  Widget _buildEditableCheckbox(ResponsiveHelper responsive, HabitEntry entry, String habitField) {
    bool checked = false;
    switch (habitField) {
      case 'sleep':
        checked = entry.sleep;
        break;
      case 'eatHealthy':
        checked = entry.eatHealthy;
        break;
      case 'socialMedia':
        checked = entry.socialMedia;
        break;
      case 'noPornAlcohol':
        checked = entry.noPornAlcohol;
        break;
      case 'drinkWater':
        checked = entry.drinkWater;
        break;
      case 'study':
        checked = entry.study;
        break;
      case 'exercise':
        checked = entry.exercise;
        break;
      case 'read':
        checked = entry.read;
        break;
      case 'journal':
        checked = entry.journal;
        break;
      case 'planTomorrow':
        checked = entry.planTomorrow;
        break;
    }

    final size = responsive.checkboxSize;

    return InkWell(
      onTap: () async {
        // Toggle the habit value
        switch (habitField) {
          case 'sleep':
            entry.sleep = !entry.sleep;
            break;
          case 'eatHealthy':
            entry.eatHealthy = !entry.eatHealthy;
            break;
          case 'socialMedia':
            entry.socialMedia = !entry.socialMedia;
            break;
          case 'noPornAlcohol':
            entry.noPornAlcohol = !entry.noPornAlcohol;
            break;
          case 'drinkWater':
            entry.drinkWater = !entry.drinkWater;
            break;
          case 'study':
            entry.study = !entry.study;
            break;
          case 'exercise':
            entry.exercise = !entry.exercise;
            break;
          case 'read':
            entry.read = !entry.read;
            break;
          case 'journal':
            entry.journal = !entry.journal;
            break;
          case 'planTomorrow':
            entry.planTomorrow = !entry.planTomorrow;
            break;
        }
        
        // Recalculate percentage
        entry.dailyPercentage = _calculateDailyPercentage(entry);
        
        // Find if this entry exists in the database
        final existingIndex = _entries.indexWhere((e) => 
          e.date.year == entry.date.year && 
          e.date.month == entry.date.month && 
          e.date.day == entry.date.day
        );
        
        // Check if any habit is checked for this day
        final hasAnyChecked = entry.sleep || entry.eatHealthy || entry.socialMedia || 
                             entry.noPornAlcohol || entry.drinkWater || entry.study || 
                             entry.exercise || entry.read || entry.journal || entry.planTomorrow;
        
        if (hasAnyChecked) {
          // If any habit is checked, save/update the entry
          setState(() {
            if (existingIndex == -1) {
              _entries.add(entry);
              _entries.sort((a, b) => b.date.compareTo(a.date));
            } else {
              _entries[existingIndex] = entry;
            }
          });
          // Save to database
          print('💾 Saving ${_entries.length} entries to storage');
          await StorageService.instance.saveHabitEntries(_entries);
          print('✅ Save completed');
        } else {
          // If all habits are unchecked, remove the entry from database
          if (existingIndex != -1) {
            setState(() {
              _entries.removeAt(existingIndex);
            });
            // Save updated list (without this entry) to database
            print('🗑️ Removing entry, saving ${_entries.length} entries');
            await StorageService.instance.saveHabitEntries(_entries);
            print('✅ Save completed');
          }
        }
        
        // Reload entries from storage to ensure consistency
        final reloadedEntries = await StorageService.instance.loadHabitEntries();
        print('🔄 Reloaded ${reloadedEntries.length} entries from storage');
        setState(() {
          _entries = reloadedEntries;
        });
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: checked ? Colors.blue : Colors.transparent,
          border: Border.all(
            color: checked ? Colors.blue : const Color(0xFFD1D5DB),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: checked
            ? Icon(
                Icons.check,
                size: size * 0.65,
                color: Colors.white,
              )
            : null,
      ),
    );
  }

  int _calculateDailyPercentage(HabitEntry entry) {
    int completed = 0;
    if (entry.sleep) completed++;
    if (entry.eatHealthy) completed++;
    if (entry.socialMedia) completed++;
    if (entry.noPornAlcohol) completed++;
    if (entry.drinkWater) completed++;
    if (entry.study) completed++;
    if (entry.exercise) completed++;
    if (entry.read) completed++;
    if (entry.journal) completed++;
    if (entry.planTomorrow) completed++;
    return ((completed / 10) * 100).round();
  }

  Widget _buildMonthlyOverviewView(ResponsiveHelper responsive) {
    final monthlyData = HabitDataService.getMonthlyOverview(_entries);
    final allMonths = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];

    return SingleChildScrollView(
      padding: responsive.padding(const EdgeInsets.all(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.grid_view, size: responsive.mediumIconSize),
              SizedBox(width: responsive.spacing(8)),
              Text(
                'Monthly Overview',
                style: TextStyle(
                  fontSize: responsive.fontSize(20),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: responsive.spacing(16)),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: responsive.gridColumnCount,
              crossAxisSpacing: responsive.spacing(16),
              mainAxisSpacing: responsive.spacing(16),
              childAspectRatio: responsive.value<double>(
                mobile: 1.0,
                tablet: 1.1,
                desktop: 1.2,
                largeDesktop: 1.3,
              ),
            ),
            itemCount: allMonths.length,
            itemBuilder: (context, index) {
              final monthName = allMonths[index];
              final monthData = monthlyData.firstWhere(
                (m) => m.name.startsWith(monthName),
                orElse: () => MonthlyOverview(
                  name: monthName,
                  monthlyAverage: 0,
                  progressBar: '',
                  daysTracked: 0,
                ),
              );

              return _buildMonthCard(responsive, monthName, monthData);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHabitStatistics(ResponsiveHelper responsive, List<HabitEntry> entries) {
    // Calculate habit completion percentages
    Map<String, int> habitStats = {};
    for (int i = 0; i < habitNames.length && i < 10; i++) {
      int completed = 0;
      for (var entry in entries) {
        if (_getHabitValueByIndex(entry, i)) {
          completed++;
        }
      }
      int percentage = entries.isEmpty ? 0 : ((completed / entries.length) * 100).round();
      habitStats[habitNames[i]] = percentage;
    }

    return Card(
      child: Padding(
        padding: responsive.padding(const EdgeInsets.all(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '📊 Habit Statistics',
              style: TextStyle(
                fontSize: responsive.fontSize(18),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: responsive.spacing(16)),
            responsive.isSmall
                ? Column(
                    children: [
                      _buildBarChart(responsive, habitStats),
                      SizedBox(height: responsive.spacing(16)),
                      _buildPieChart(responsive, habitStats),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: _buildBarChart(responsive, habitStats),
                      ),
                      SizedBox(width: responsive.spacing(16)),
                      Expanded(
                        child: _buildPieChart(responsive, habitStats),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  bool _getHabitValueByIndex(HabitEntry entry, int index) {
    final habitFields = ['sleep', 'eatHealthy', 'socialMedia', 'noPornAlcohol', 
                        'drinkWater', 'study', 'exercise', 'read', 'journal', 'planTomorrow'];
    if (index < habitFields.length) {
      return _getHabitValue(entry, habitFields[index]);
    }
    return false;
  }

  Widget _buildBarChart(ResponsiveHelper responsive, Map<String, int> habitStats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Completion Rate by Habit',
          style: TextStyle(
            fontSize: responsive.fontSize(14),
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: responsive.spacing(12)),
        ...habitStats.entries.map((entry) {
          Color barColor;
          if (entry.value < 50) {
            barColor = Colors.red;
          } else if (entry.value < 80) {
            barColor = Colors.orange;
          } else {
            barColor = Colors.green;
          }

          return Padding(
            padding: EdgeInsets.only(bottom: responsive.spacing(8)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        entry.key,
                        style: TextStyle(fontSize: responsive.fontSize(12)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: responsive.spacing(8)),
                    Expanded(
                      flex: 7,
                      child: Stack(
                        children: [
                          Container(
                            height: 20,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: entry.value / 100,
                            child: Container(
                              height: 20,
                              decoration: BoxDecoration(
                                color: barColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: responsive.spacing(8)),
                    SizedBox(
                      width: 40,
                      child: Text(
                        '${entry.value}%',
                        style: TextStyle(
                          fontSize: responsive.fontSize(12),
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildPieChart(ResponsiveHelper responsive, Map<String, int> habitStats) {
    // Get top 5 habits
    var sortedHabits = habitStats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    var topHabits = sortedHabits.take(5).toList();
    
    int total = topHabits.fold(0, (sum, entry) => sum + entry.value);
    
    List<Color> colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Top 5 Habits',
          style: TextStyle(
            fontSize: responsive.fontSize(14),
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: responsive.spacing(12)),
        Center(
          child: SizedBox(
            width: responsive.value<double>(
              mobile: 150,
              tablet: 180,
              desktop: 200,
              largeDesktop: 220,
            ),
            height: responsive.value<double>(
              mobile: 150,
              tablet: 180,
              desktop: 200,
              largeDesktop: 220,
            ),
            child: CustomPaint(
              size: Size(
                responsive.value<double>(
                  mobile: 150,
                  tablet: 180,
                  desktop: 200,
                  largeDesktop: 220,
                ),
                responsive.value<double>(
                  mobile: 150,
                  tablet: 180,
                  desktop: 200,
                  largeDesktop: 220,
                ),
              ),
              painter: _PieChartPainter(topHabits, colors, total),
            ),
          ),
        ),
        SizedBox(height: responsive.spacing(12)),
        ...topHabits.asMap().entries.map((item) {
          int index = item.key;
          var entry = item.value;
          double percentage = total > 0 ? (entry.value / total * 100) : 0;
          
          return Padding(
            padding: EdgeInsets.only(bottom: responsive.spacing(4)),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: colors[index],
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: responsive.spacing(8)),
                Expanded(
                  child: Text(
                    entry.key,
                    style: TextStyle(fontSize: responsive.fontSize(11)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: responsive.fontSize(11),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildMonthCard(ResponsiveHelper responsive, String monthName, MonthlyOverview data) {
    int percentage = data.monthlyAverage.round();
    int filledBlocks = (percentage / 10).floor();

    // Determine color based on percentage
    Color getBlockColor() {
      if (percentage < 50) {
        return Colors.red;
      } else if (percentage < 80) {
        return Colors.yellow;
      } else {
        return Colors.green;
      }
    }

    final blockSize = responsive.value<double>(
      mobile: 10,
      tablet: 12,
      desktop: 14,
      largeDesktop: 16,
    );

    return Card(
      elevation: 1,
      child: Padding(
        padding: responsive.padding(const EdgeInsets.all(16)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              monthName.substring(0, 3),
              style: TextStyle(
                fontSize: responsive.fontSize(22),
                fontWeight: FontWeight.w300,
                letterSpacing: 2,
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.calendar_month,
                  size: responsive.smallIconSize,
                  color: Colors.grey,
                ),
                SizedBox(width: responsive.spacing(4)),
                Text(
                  '${data.daysTracked}',
                  style: TextStyle(
                    fontSize: responsive.fontSize(12),
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            SizedBox(height: responsive.spacing(8)),
            Wrap(
              spacing: responsive.spacing(2),
              runSpacing: responsive.spacing(2),
              children: List.generate(
                10,
                (index) => Container(
                  width: blockSize,
                  height: blockSize,
                  decoration: BoxDecoration(
                    color: index < filledBlocks ? getBlockColor() : const Color(0xFFE5E5E5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
            SizedBox(height: responsive.spacing(4)),
            Text(
              '$percentage%',
              style: TextStyle(
                fontSize: responsive.fontSize(12),
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }



  Future<void> _loadCSVData() async {
    setState(() => _isLoading = true);

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        withData: true,
      );

      if (result != null && result.files.single.bytes != null) {
        final entries = await HabitDataService.loadFromCSV(result.files.single.bytes!);

        setState(() {
          _entries = entries;
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

  void _addNewDay() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    
    if (selectedDate != null) {
      // Check if entry already exists
      final existingIndex = _entries.indexWhere((entry) =>
          entry.date.year == selectedDate.year &&
          entry.date.month == selectedDate.month &&
          entry.date.day == selectedDate.day);

      if (existingIndex == -1) {
        // Add new entry
        final newEntry = HabitEntry(
          date: selectedDate,
          drinkWater: false,
          eatHealthy: false,
          exercise: false,
          journal: false,
          month: DateFormat('MMMM').format(selectedDate),
          noPornAlcohol: false,
          planTomorrow: false,
          progressBar: '⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜ 0%',
          read: false,
          sleep: false,
          socialMedia: false,
          study: false,
          dailyPercentage: 0,
          notes: '',
        );
        
        setState(() {
          _entries.add(newEntry);
          _entries.sort((a, b) => b.date.compareTo(a.date));
        });
        
        // Save to storage (await to ensure write completes)
        await StorageService.instance.saveHabitEntries(_entries);
      }
    }
  }

  void _addNewHabit() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Habit'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter habit name with emoji (e.g., Meditate 🧘)',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                setState(() {
                  habitNames.add(controller.text.trim());
                });
                await StorageService.instance.saveHabitNames(habitNames);
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _editHabit(int index) {
    final controller = TextEditingController(text: habitNames[index]);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Habit'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter habit name with emoji',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                setState(() {
                  habitNames[index] = controller.text.trim();
                });
                await StorageService.instance.saveHabitNames(habitNames);
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _editColumnHeader(int index) {
    final controller = TextEditingController(text: habitNames[index]);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Column Header'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter habit name (emoji will be added automatically)',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                setState(() {
                  habitNames[index] = controller.text.trim();
                });
                await StorageService.instance.saveHabitNames(habitNames);
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _deleteHabit(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Habit'),
        content: Text('Are you sure you want to delete "${habitNames[index]}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              setState(() {
                habitNames.removeAt(index);
              });
              await StorageService.instance.saveHabitNames(habitNames);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _PieChartPainter extends CustomPainter {
  final List<MapEntry<String, int>> data;
  final List<Color> colors;
  final int total;

  _PieChartPainter(this.data, this.colors, this.total);

  @override
  void paint(Canvas canvas, Size size) {
    if (total == 0 || data.isEmpty) {
      // Draw a placeholder circle
      final paint = Paint()
        ..color = Colors.grey.shade300
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
        Offset(size.width / 2, size.height / 2),
        size.width / 2,
        paint,
      );
      return;
    }

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width < size.height ? size.width : size.height) / 2 * 0.9;
    
    double startAngle = -3.14159 / 2; // Start from top

    for (int i = 0; i < data.length; i++) {
      final sweepAngle = (data[i].value / total) * 2 * 3.14159;
      
      final paint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      startAngle += sweepAngle;
    }

    // Draw white circle in center to make it a donut chart
    final centerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.5, centerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
