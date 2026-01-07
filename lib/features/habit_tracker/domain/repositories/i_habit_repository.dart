import '../entities/habit_entity.dart';

abstract class IHabitRepository {
  Future<void> createHabit(HabitEntity habit);
  Future<List<HabitEntity>> getHabits();
  Future<void> updateHabit(HabitEntity habit);
  Future<void> deleteHabit(String id);
}