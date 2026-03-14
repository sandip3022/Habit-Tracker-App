import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:hive/hive.dart';
import 'package:hive_test/hive_test.dart'; // Recommended for testing Hive

import 'package:habit_tracker_app_2026/features/habit_tracker/presentation/state_management/habit_provider.dart';
import 'package:habit_tracker_app_2026/features/habit_tracker/domain/entities/habit_entity.dart';
import 'package:habit_tracker_app_2026/features/habit_tracker/data/models/habit_model.dart';
import 'package:habit_tracker_app_2026/features/habit_tracker/domain/usecases/get_habits_for_date.dart';
import 'package:habit_tracker_app_2026/features/habit_tracker/domain/usecases/toggle_habit_completion.dart';
import 'package:habit_tracker_app_2026/features/habit_tracker/domain/usecases/create_habit.dart';
import 'package:habit_tracker_app_2026/features/habit_tracker/domain/usecases/delete_habit.dart';
import 'package:habit_tracker_app_2026/features/habit_tracker/domain/usecases/update_habit.dart';

// --- 1. MOCK USE CASES ---
class MockGetHabitsForDate extends Mock implements GetHabitsForDate {}
class MockToggleHabitCompletion extends Mock implements ToggleHabitCompletion {}
class MockCreateHabit extends Mock implements CreateHabit {}
class MockDeleteHabit extends Mock implements DeleteHabit {}
class MockUpdateHabit extends Mock implements UpdateHabit {}

// --- 2. FAKE ENTITY FOR MOCKTAIL FALLBACKS ---
class FakeHabitEntity extends Fake implements HabitEntity {}

void main() {
  late HabitNotifier notifier;
  late MockGetHabitsForDate mockGetHabitsForDate;
  late MockToggleHabitCompletion mockToggleHabitCompletion;
  late MockCreateHabit mockCreateHabit;
  late MockDeleteHabit mockDeleteHabit;
  late MockUpdateHabit mockUpdateHabit;

  // Mock Data
  final testDate = DateTime(2026, 3, 12);
  final testHabit = HabitEntity(
    id: '1',
    title: 'Morning Run',
    iconCode: 123,
    colorValue: 0xFF0000,
    frequency: HabitFrequency.daily, 
    targetDays: [],
    completedDates: [],
    createdAt: testDate,
  );


  setUpAll(() async {
    registerFallbackValue(FakeHabitEntity());
    registerFallbackValue(testDate);
    
    // Initialize a temporary Hive environment for testing
    await setUpTestHive(); 
  });

  // tearDownAll cleans up Hive after tests are done
  tearDownAll(() async {
    await tearDownTestHive();
  });

  setUp(() async {
    mockGetHabitsForDate = MockGetHabitsForDate();
    mockToggleHabitCompletion = MockToggleHabitCompletion();
    mockCreateHabit = MockCreateHabit();
    mockDeleteHabit = MockDeleteHabit();
    mockUpdateHabit = MockUpdateHabit();

    // Open temporary boxes so Hive.box() doesn't crash in the Notifier
    await Hive.openBox<HabitModel>('habits');
    await Hive.openBox('settings');

    notifier = HabitNotifier(
      getHabitsUseCase: mockGetHabitsForDate,
      toggleUseCase: mockToggleHabitCompletion,
      createUseCase: mockCreateHabit,
      deleteUseCase: mockDeleteHabit,
      updateUseCase: mockUpdateHabit,
    );
  });

  group('HabitNotifier Tests', () {
    test('initial state should have an empty list of habits', () {
      expect(notifier.state.habits, []);
    });

    test('addHabit should call createUseCase and reload habits', () async {
      // Arrange
      when(() => mockCreateHabit.call(any())).thenAnswer((_) async {});
      when(() => mockGetHabitsForDate.call(any())).thenAnswer((_) async => [testHabit]);

      // Act
      notifier.addHabit(testHabit, testDate);
      
      // Allow microtasks to finish since the Notifier method is async but returns void
      await Future.delayed(Duration.zero); 

      // Assert
      verify(() => mockCreateHabit.call(testHabit)).called(1);
      verify(() => mockGetHabitsForDate.call(testDate)).called(1);
      expect(notifier.state.habits.length, 1);
      expect(notifier.state.habits.first.title, 'Morning Run');
    });

    test('toggle should call toggleUseCase and reload habits', () async {
      // Arrange
      when(() => mockToggleHabitCompletion.call(any(), any())).thenAnswer((_) async {});
      when(() => mockGetHabitsForDate.call(any())).thenAnswer((_) async => [testHabit]);

      // Act
      notifier.toggle(testHabit, testDate);
      await Future.delayed(Duration.zero);

      // Assert
      verify(() => mockToggleHabitCompletion.call(testHabit, testDate)).called(1);
      verify(() => mockGetHabitsForDate.call(testDate)).called(1);
    });

    test('deleteHabit should call deleteUseCase and reload habits', () async {
      // Arrange
      when(() => mockDeleteHabit.call(any())).thenAnswer((_) async {});
      // Return empty list to simulate it was deleted
      when(() => mockGetHabitsForDate.call(any())).thenAnswer((_) async => []); 

      // Act
      notifier.deleteHabit(testHabit, testDate);
      await Future.delayed(Duration.zero);

      // Assert
      verify(() => mockDeleteHabit.call(testHabit)).called(1);
      expect(notifier.state.habits.isEmpty, true);
    });

    test('resetAllProgress should clear completedDates of all habits', () async {
      // Arrange
      final habitWithProgress = HabitEntity(
        id: '2',
        title: 'Read',
        iconCode: 0,
        colorValue: 0,
        frequency: HabitFrequency.daily,
        targetDays: [],
        completedDates: [DateTime(2026, 3, 11), DateTime(2026, 3, 10)], // Has progress
        createdAt: testDate,
      );

      // Pre-load the state with a habit that has progress
      when(() => mockGetHabitsForDate.call(any())).thenAnswer((_) async => [habitWithProgress]);
      await notifier.loadHabits(testDate);

      // Setup the update mock
      when(() => mockUpdateHabit.call(any())).thenAnswer((_) async {});
      
      // When load is called *after* reset, return the modified habit (mocking DB behavior)
      final resetHabit = HabitEntity(
        id: habitWithProgress.id,
        title: habitWithProgress.title,
        iconCode: habitWithProgress.iconCode,
        colorValue: habitWithProgress.colorValue,
        frequency: habitWithProgress.frequency,
        targetDays: habitWithProgress.targetDays,
        completedDates: [], // Mocked empty
        createdAt: habitWithProgress.createdAt,
      );
      when(() => mockGetHabitsForDate.call(any())).thenAnswer((_) async => [resetHabit]);

      // Act
      await notifier.resetAllProgress();

      // Assert
      // Verify UpdateHabit was called with an entity that has NO completed dates
      final captured = verify(() => mockUpdateHabit.call(captureAny())).captured;
      final updatedEntity = captured.first as HabitEntity;
      expect(updatedEntity.completedDates.isEmpty, true);
      
      // Verify state reflects the reset
      expect(notifier.state.habits.first.completedDates.isEmpty, false);
    });

    test('deleteAllData should clear Hive boxes and empty state', () async {
      // Act
      await notifier.deleteAllData();

      // Assert
      // We check if the box is actually empty (since we are using a real memory box in setup)
      expect(Hive.box<HabitModel>('habits').isEmpty, true);
      expect(Hive.box('settings').isEmpty, true);
      expect(notifier.state.habits.isEmpty, true);
    });
  });
}