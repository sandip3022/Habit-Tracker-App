import '../../domain/repositories/i_habit_repository.dart';
import '../../domain/entities/habit_entity.dart';
import '../datasources/local/habit_local_data_source.dart';
import '../models/habit_model.dart';

class HabitRepositoryImpl implements IHabitRepository {
  final HabitLocalDataSource localDataSource;

  HabitRepositoryImpl({required this.localDataSource});

  @override
  Future<void> createHabit(HabitEntity habit) async {
    final habitModel = HabitModel.fromEntity(habit);
    await localDataSource.cacheHabit(habitModel);
  }

  @override
  Future<List<HabitEntity>> getHabits() async {
    final models = localDataSource.getAllHabits();
    // Cast models to entities (allowed because HabitModel extends HabitEntity)
    return models.cast<HabitEntity>();
  }

  // --- IMPLEMENTATION OF UPDATE (Missing) ---
  @override
  Future<void> updateHabit(HabitEntity habit) async {
    final habitModel = HabitModel.fromEntity(habit);
    // In Hive, calling 'put' with the same ID overwrites the old data
    await localDataSource.cacheHabit(habitModel);
  }

  // --- IMPLEMENTATION OF DELETE (Missing) ---
  @override
  Future<void> deleteHabit(String id) async {
    await localDataSource.deleteHabit(id);
  }
}