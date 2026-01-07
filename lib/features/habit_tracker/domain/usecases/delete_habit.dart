import '../entities/habit_entity.dart';
import '../repositories/i_habit_repository.dart';

class DeleteHabit {
  final IHabitRepository repository;

  DeleteHabit(this.repository);

  /// Callable class method to execute the use case
  Future<void> call(HabitEntity habit) async {
    return repository.deleteHabit(habit.id);
  }
}