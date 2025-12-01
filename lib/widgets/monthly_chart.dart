import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/habit_entry.dart';

class MonthlyChart extends StatelessWidget {
  final List<MonthlyOverview> monthlyData;

  const MonthlyChart({super.key, required this.monthlyData});

  @override
  Widget build(BuildContext context) {
    if (monthlyData.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: Text('No monthly data available')),
        ),
      );
    }

    // Take last 6 months
    final recentMonths = monthlyData.length > 6
        ? monthlyData.sublist(monthlyData.length - 6)
        : monthlyData;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 100,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          '${rod.toY.toStringAsFixed(1)}%',
                          const TextStyle(color: Colors.white),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= recentMonths.length) {
                            return const Text('');
                          }
                          final month = recentMonths[value.toInt()].name.split(' ')[0];
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              month.substring(0, 3),
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text('${value.toInt()}%');
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 25,
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: recentMonths.asMap().entries.map((entry) {
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value.monthlyAverage,
                          color: entry.value.monthlyAverage >= 75
                              ? Colors.green
                              : entry.value.monthlyAverage >= 50
                                  ? Colors.orange
                                  : Colors.red,
                          width: 20,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
