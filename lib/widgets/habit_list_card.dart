import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/habit_entry.dart';

class HabitListCard extends StatefulWidget {
  final List<HabitEntry> entries;

  const HabitListCard({super.key, required this.entries});

  @override
  State<HabitListCard> createState() => _HabitListCardState();
}

class _HabitListCardState extends State<HabitListCard> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final sortedEntries = List<HabitEntry>.from(widget.entries)
      ..sort((a, b) => b.date.compareTo(a.date));

    return Column(
      children: [
        // Date selector
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () {
                  setState(() {
                    _selectedDate = _selectedDate.subtract(const Duration(days: 1));
                  });
                },
              ),
              Text(
                DateFormat('MMMM d, yyyy').format(_selectedDate),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  setState(() {
                    _selectedDate = _selectedDate.add(const Duration(days: 1));
                  });
                },
              ),
            ],
          ),
        ),
        
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sortedEntries.length,
            itemBuilder: (context, index) {
              final entry = sortedEntries[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: entry.isSuccessfulDay ? Colors.green : Colors.orange,
                    child: Text(
                      '${entry.dailyPercentage}%',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                  title: Text(DateFormat('MMMM d, yyyy').format(entry.date)),
                  subtitle: Text('${entry.completedHabits}/10 habits completed'),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildHabitRow('Sleep 7-8 hours', entry.sleep),
                          _buildHabitRow('🥗 Eat healthy meals', entry.eatHealthy),
                          _buildHabitRow('📱 Social media ≤ 90min', entry.socialMedia),
                          _buildHabitRow('🚫 No porn/alcohol', entry.noPornAlcohol),
                          _buildHabitRow('💧 Drink 2L water', entry.drinkWater),
                          _buildHabitRow('💻 Study ≥ 2 hours', entry.study),
                          _buildHabitRow('🏋🏻‍♀️ Exercise 30 minutes', entry.exercise),
                          _buildHabitRow('📖 Read 30 minutes', entry.read),
                          _buildHabitRow('🖋️ Journal & self-reflect', entry.journal),
                          _buildHabitRow('📋 Plan tomorrow\'s tasks', entry.planTomorrow),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHabitRow(String habit, bool completed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            completed ? Icons.check_circle : Icons.cancel,
            color: completed ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              habit,
              style: TextStyle(
                decoration: completed ? null : TextDecoration.lineThrough,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
