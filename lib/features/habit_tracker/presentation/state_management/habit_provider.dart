import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker_app_2026/features/habit_tracker/domain/usecases/delete_habit.dart';
import 'package:habit_tracker_app_2026/features/habit_tracker/domain/usecases/update_habit.dart';
import '../../domain/entities/habit_entity.dart';
import '../../domain/usecases/get_habits_for_date.dart';
import '../../domain/usecases/toggle_habit_completion.dart';
import '../../domain/usecases/create_habit.dart'; // Import this!

// 1. Define State
class HabitState {
  final List<HabitEntity> habits;
  HabitState(this.habits);
}

// 2. Define Notifier
class HabitNotifier extends StateNotifier<HabitState> {
  // Define the use cases as properties
  final GetHabitsForDate _getHabitsUseCase;
  final ToggleHabitCompletion _toggleUseCase;
  final CreateHabit _createUseCase;
  final UpdateHabit _updateHabitUseCase;
  final DeleteHabit _deleteHabitUseCase;

  // Constructor using NAMED parameters (Fixes the main.dart error)
  HabitNotifier({
    required GetHabitsForDate getHabitsUseCase,
    required ToggleHabitCompletion toggleUseCase,
    required CreateHabit createUseCase,
    required UpdateHabit updateHabitUseCase,
    required DeleteHabit deleteHabitUseCase,
  })  : _getHabitsUseCase = getHabitsUseCase,
        _toggleUseCase = toggleUseCase,
        _createUseCase = createUseCase,
        _updateHabitUseCase = updateHabitUseCase,
        _deleteHabitUseCase = deleteHabitUseCase,
        super(HabitState([]));

  void loadHabits() async {
    final habits = await _getHabitsUseCase.call(DateTime.now());
    state = HabitState(habits);
  }

  void toggle(HabitEntity habit) async {
    await _toggleUseCase.call(habit, DateTime.now());
    loadHabits(); 
  }

  void addHabit(HabitEntity habit) async {
  print("DEBUG: Adding habit '${habit.title}'"); // Check 1
  print("DEBUG: Frequency: ${habit.frequency}"); // Check 2
  print("DEBUG: Days: ${habit.targetDays}");     // Check 3
  
  await _createUseCase.call(habit);
  
  print("DEBUG: Saved to Hive!");                // Check 4
  loadHabits();
  }

  void updateHabit(HabitEntity habit) async {
    await _updateHabitUseCase.call(habit);
    loadHabits();
  }

   void deleteHabit(HabitEntity habit) async {
    await _deleteHabitUseCase.call(habit);
    loadHabits();
  }
}