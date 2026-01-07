import 'package:habit_tracker_app_2026/features/habit_tracker/data/models/habit_model.dart';
import 'package:hive/hive.dart';

abstract class HabitLocalDataSource {
  Future<void> cacheHabit(HabitModel habit);
  List<HabitModel> getAllHabits();
  
  Future<void> deleteHabit(String id);
}

class HabitLocalDataSourceImpl implements HabitLocalDataSource {
  final Box<HabitModel> habitBox;

  HabitLocalDataSourceImpl({required this.habitBox});

  @override
  Future<void> cacheHabit(HabitModel habit) async {
    await habitBox.put(habit.id, habit);
  }

  @override
  List<HabitModel> getAllHabits() {
    return habitBox.values.toList();
  }

  @override
  Future<void> deleteHabit(String id) async {
    await habitBox.delete(id);
  }
}