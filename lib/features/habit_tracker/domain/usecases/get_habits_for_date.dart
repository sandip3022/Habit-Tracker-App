import '../entities/habit_entity.dart';
import '../repositories/i_habit_repository.dart';

class GetHabitsForDate {
  final IHabitRepository repository;

  GetHabitsForDate(this.repository);

  /// Retrieves habits relevant for a specific date.
  /// Currently returns all habits, but business logic for filtering
  /// (e.g., "Mon/Wed/Fri only") belongs here.
  Future<List<HabitEntity>> call(DateTime date) async {
    final allHabits = await repository.getHabits();
    
    // Business Logic: Filter habits that are scheduled for this specific date.
    // We delegate the "check" to the Entity itself to keep this clean.
    return allHabits.where((habit) => habit.isScheduledFor(date)).toList();
  }
}
