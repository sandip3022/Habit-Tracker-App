import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/habit_entity.dart';
import '../../domain/usecases/get_habits_for_date.dart';
import '../../domain/usecases/toggle_habit_completion.dart';
import '../../domain/usecases/create_habit.dart';
import '../../domain/usecases/delete_habit.dart';
import '../../domain/usecases/update_habit.dart';

// --- NEW: DATE PROVIDER ---
// Stores the currently selected date (Defaults to Today)
final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

class HabitState {
  final List<HabitEntity> habits;
  HabitState(this.habits);
}

class HabitNotifier extends StateNotifier<HabitState> {
  final GetHabitsForDate _getHabitsUseCase;
  final ToggleHabitCompletion _toggleUseCase;
  final CreateHabit _createUseCase;
  final DeleteHabit _deleteUseCase;
  final UpdateHabit _updateUseCase;

  HabitNotifier({
    required GetHabitsForDate getHabitsUseCase,
    required ToggleHabitCompletion toggleUseCase,
    required CreateHabit createUseCase,
    required DeleteHabit deleteUseCase,
    required UpdateHabit updateUseCase,
  })  : _getHabitsUseCase = getHabitsUseCase,
        _toggleUseCase = toggleUseCase,
        _createUseCase = createUseCase,
        _deleteUseCase = deleteUseCase,
        _updateUseCase = updateUseCase,
        super(HabitState([]));

  // --- UPDATED: Accepts 'date' parameter ---
  void loadHabits(DateTime date) async {
    final habits = await _getHabitsUseCase.call(date);
    state = HabitState(habits);
  }

  // --- UPDATED: Accepts 'date' parameter ---
  void toggle(HabitEntity habit, DateTime date) async {
    await _toggleUseCase.call(habit, date); // Toggle for the SPECIFIC date
    loadHabits(date); // Reload that date's data
  }

  // Habits are always created for "Lifecycle", so we usually reload the *current* view
  void addHabit(HabitEntity habit, DateTime currentDate) async {
    await _createUseCase.call(habit);
    loadHabits(currentDate);
  }

  void updateHabit(HabitEntity habit, DateTime currentDate) async {
    await _updateUseCase.call(habit);
    loadHabits(currentDate);
  }

  void deleteHabit(HabitEntity habit, DateTime currentDate) async {
    await _deleteUseCase.call(habit);
    loadHabits(currentDate);
  }
}