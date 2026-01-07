import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../domain/entities/habit_entity.dart';

class HabitHistoryPage extends StatefulWidget {
  final HabitEntity habit;

  const HabitHistoryPage({super.key, required this.habit});

  @override
  State<HabitHistoryPage> createState() => _HabitHistoryPageState();
}

class _HabitHistoryPageState extends State<HabitHistoryPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Color(widget.habit.colorValue);

    return Scaffold(
      backgroundColor: Colors.white, // Clean white look for calendar
      appBar: AppBar(
        title: Text(widget.habit.title, style: const TextStyle(color: Colors.black)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildCalendar(primaryColor),
            const Divider(),
            _buildSummary(primaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendar(Color color) {
    return TableCalendar(
      firstDay: DateTime.utc(2026, 1, 2),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
      },
      headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
      
      // LOGIC: Show colored circles on days where habit matches history
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, day, focusedDay) => _buildDayCell(day, color),
        todayBuilder: (context, day, focusedDay) => _buildDayCell(day, color, isToday: true),
        selectedBuilder: (context, day, focusedDay) => _buildDayCell(day, color), // Handle selection same as default
      ),
    );
  }

  Container? _buildDayCell(DateTime day, Color color, {bool isToday = false}) {
    // Check if day exists in Entity's completedDates
    // IMPORTANT: Compare Y/M/D only
    final isCompleted = widget.habit.completedDates.any((d) => 
      d.year == day.year && d.month == day.month && d.day == day.day
    );

    if (isCompleted) {
      return Container(
        margin: const EdgeInsets.all(6.0),
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Center(child: Text('${day.day}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
      );
    }

    if (isToday) {
      return Container(
        margin: const EdgeInsets.all(6.0),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 2),
        ),
        child: Center(child: Text('${day.day}', style: TextStyle(color: color, fontWeight: FontWeight.bold))),
      );
    }

    return null; // Default styling
  }

  Widget _buildSummary(Color color) {
    final total = widget.habit.completedDates.length;
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _statCard("Total", "$total", color),
          // You can calculate streak here or pass it in Entity
          _statCard("Streak", "Calculate", Colors.grey), 
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }
}