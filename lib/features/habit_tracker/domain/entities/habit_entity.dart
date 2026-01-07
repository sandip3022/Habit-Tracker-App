import 'package:flutter/material.dart'; // Needed for Color

enum HabitFrequency { daily, weekly, specificDays }

class HabitEntity {
  final String id;
  final String title;
  final int iconCode;
  final int colorValue;
  final DateTime? createdAt;
  final DateTime? validUntil;
  final List<DateTime> completedDates;

  final HabitFrequency frequency;
  final List<int> targetDays;

  HabitEntity({
    required this.id,
    required this.title,
    required this.iconCode,
    required this.colorValue,
    this.createdAt,
    this.validUntil,
    required this.frequency,
    required this.targetDays,
    required this.completedDates,
  });

  /// Helper to convert int to Color
  Color get color => Color(colorValue);

  /// Checks if the habit is completed on a specific date (Year/Month/Day)
  bool isCompletedOn(DateTime date) {
    return completedDates.any(
      (d) => d.year == date.year && d.month == date.month && d.day == date.day,
    );
  }

  /// Checks if the habit should appear on the dashboard for this date
  /// (Currently returns true for everything, can be expanded for specific days later)
  bool isScheduledFor(DateTime date) {
    if (frequency == HabitFrequency.daily) {
      return true;
    }

    if (frequency == HabitFrequency.specificDays) {
      // DateTime.weekday: 1 = Monday, 7 = Sunday
      return targetDays.contains(date.weekday);
    }

    return true;
  }
}
