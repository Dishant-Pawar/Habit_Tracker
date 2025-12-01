import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/habit_entry.dart';

class HabitHeatmap extends StatefulWidget {
  final List<HabitEntry> entries;

  const HabitHeatmap({super.key, required this.entries});

  @override
  State<HabitHeatmap> createState() => _HabitHeatmapState();
}

class _HabitHeatmapState extends State<HabitHeatmap> {
  DateTime _currentMonth = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Month navigation
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () {
                  setState(() {
                    _currentMonth = DateTime(
                      _currentMonth.year,
                      _currentMonth.month - 1,
                    );
                  });
                },
              ),
              Text(
                DateFormat('MMMM yyyy').format(_currentMonth),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  setState(() {
                    _currentMonth = DateTime(
                      _currentMonth.year,
                      _currentMonth.month + 1,
                    );
                  });
                },
              ),
            ],
          ),
        ),

        // Heatmap
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: _buildHeatmap(),
          ),
        ),

        // Legend
        Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildLegendItem('0%', Colors.grey[300]!),
                _buildLegendItem('1-49%', Colors.red[300]!),
                _buildLegendItem('50-74%', Colors.orange[300]!),
                _buildLegendItem('75-99%', Colors.lightGreen[300]!),
                _buildLegendItem('100%', Colors.green),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeatmap() {
    // Get all days in the current month
    final lastDay = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    final daysInMonth = lastDay.day;

    // Create a map of entries by date
    final entriesByDate = <DateTime, HabitEntry>{};
    for (var entry in widget.entries) {
      final dateOnly = DateTime(entry.date.year, entry.date.month, entry.date.day);
      entriesByDate[dateOnly] = entry;
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: daysInMonth,
      itemBuilder: (context, index) {
        final day = index + 1;
        final date = DateTime(_currentMonth.year, _currentMonth.month, day);
        final entry = entriesByDate[date];

        return GestureDetector(
          onTap: () {
            if (entry != null) {
              _showDayDetails(context, entry);
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: _getColorForPercentage(entry?.dailyPercentage ?? 0),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.grey[300]!,
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                '$day',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: (entry?.dailyPercentage ?? 0) > 50
                      ? Colors.white
                      : Colors.black87,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getColorForPercentage(int percentage) {
    if (percentage == 0) return Colors.grey[300]!;
    if (percentage < 50) return Colors.red[300]!;
    if (percentage < 75) return Colors.orange[300]!;
    if (percentage < 100) return Colors.lightGreen[300]!;
    return Colors.green;
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 10)),
      ],
    );
  }

  void _showDayDetails(BuildContext context, HabitEntry entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(DateFormat('MMMM d, yyyy').format(entry.date)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Completion: ${entry.dailyPercentage}%',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text('Habits completed: ${entry.completedHabits}/10'),
            const SizedBox(height: 8),
            if (entry.notes.isNotEmpty) ...[
              const Divider(),
              const Text(
                'Notes:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(entry.notes),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
