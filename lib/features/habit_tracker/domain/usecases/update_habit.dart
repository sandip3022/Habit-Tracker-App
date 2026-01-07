import '../entities/habit_entity.dart';
import '../repositories/i_habit_repository.dart';

class UpdateHabit {
  final IHabitRepository repository;

  UpdateHabit(this.repository);

  /// Callable class method to execute the use case
  Future<void> call(HabitEntity habit) async {
    return repository.updateHabit(habit);
  }
}