import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker_app_2026/features/habit_tracker/domain/entities/habit_entity.dart';

void main() {
  group('HabitEntity Tests', () {
    test('should initialize with 0 streak and empty completed dates', () {
      final habit = HabitEntity(
        id: '123',
        title: 'Read 10 Pages',
        iconCode: 12345,
        colorValue: 0xFF0000,
        frequency: HabitFrequency.daily,
        targetDays: [1, 2, 3, 4, 5, 6, 7],
        createdAt: DateTime(2026, 3, 12),
        completedDates: [], // Should start empty
      );

      expect(habit.title, 'Read 10 Pages');
      expect(habit.currentStreak, 0); // Should default to 0
      expect(habit.completedDates.isEmpty, true); // Should start empty
    });
  });
}