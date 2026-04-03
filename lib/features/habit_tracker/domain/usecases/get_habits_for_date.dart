import '../entities/habit_entity.dart';
import '../repositories/i_habit_repository.dart';

class GetHabitsForDate {
  final IHabitRepository repository;

  GetHabitsForDate(this.repository);

  /// Retrieves habits relevant for a specific date.
  Future<List<HabitEntity>> call(DateTime date) async {
    final allHabits = await repository.getHabits();
    
    //  Filter habits that are scheduled for this specific date.
    return allHabits.where((habit) => habit.isScheduledFor(date)).toList();
  }
}
