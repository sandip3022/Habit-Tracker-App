import 'package:flutter/material.dart';
import 'package:habit_tracker_app_2026/features/habit_tracker/domain/entities/habit_entity.dart';
import 'package:habit_tracker_app_2026/features/habit_tracker/presentation/pages/add_habit_page.dart';
import 'package:habit_tracker_app_2026/features/habit_tracker/presentation/pages/habit_history_page.dart';
import 'package:habit_tracker_app_2026/features/habit_tracker/presentation/state_management/habit_provider.dart';
import 'package:habit_tracker_app_2026/features/habit_tracker/presentation/widgets/date_selector.dart';
import 'package:habit_tracker_app_2026/features/habit_tracker/presentation/widgets/habit_tile.dart';
import 'package:habit_tracker_app_2026/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class JournalPage extends ConsumerStatefulWidget {
   const JournalPage({super.key});

  @override
  ConsumerState<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends ConsumerState<JournalPage> {
 @override
  void initState() {
    super.initState();
    // Load habits for the INITIAL date (Today)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final date = ref.read(selectedDateProvider);
      ref.read(habitNotifierProvider.notifier).loadHabits(date);
    });
  }


    HabitState get habitState => ref.watch(habitNotifierProvider);

    DateTime get selectedDate => ref.watch(selectedDateProvider); 
 // Watch for UI updates
void _changeDate(int days) {
    // 1. Update the Date Provider
    final currentDate = ref.read(selectedDateProvider);
    final newDate = currentDate.add(Duration(days: days));
    
    ref.read(selectedDateProvider.notifier).state = newDate;

    // 2. Reload Habits for the NEW date
    ref.read(habitNotifierProvider.notifier).loadHabits(newDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // --- 1. DATE NAVIGATOR ---
            DateSelector(
              selectedDate: selectedDate,
              onPrevious: () => _changeDate(-1),
              onNext: () => _changeDate(1),
            ),
            
            // --- 2. PROGRESS BAR (Optional - keep or remove) ---
            // If you keep it, make sure it calculates based on 'habitState.habits'
            
            const SizedBox(height: 10),

            // --- 3. HABIT LIST ---
            Expanded(
              child: habitState.habits.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      itemCount: habitState.habits.length,
                      itemBuilder: (context, index) {
                        final habit = habitState.habits[index];
                        
                        // Check if completed on the SELECTED date
                        final isCompleted = habit.isCompletedOn(selectedDate);

                        return HabitTile(
                          habit: habit,
                          isCompletedToday: isCompleted,
                          onToggle: () {
                            // Pass selectedDate so we toggle the correct day!
                            ref.read(habitNotifierProvider.notifier).toggle(habit, selectedDate);
                          },
                          onTapBody: () {
                            Navigator.push(context, MaterialPageRoute(
                              builder: (_) => HabitHistoryPage(habit: habit)
                            ));
                          },
                          onEdit: () {
                             Navigator.push(context, MaterialPageRoute(
                               builder: (_) => AddHabitPage(habitToEdit: habit,) 
                             ));
                          },
                          onDelete: () {
                             _showDeleteConfirmation(context, habit, habit.title);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
   
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          // Pass selectedDate to refresh properly after adding
          final current = ref.read(selectedDateProvider);
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddHabitPage()));
          ref.read(habitNotifierProvider.notifier).loadHabits(current);
        },
      ),
      );
      
  }

    Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text("No habits for this day", style: TextStyle(color: Colors.grey[500])),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, HabitEntity habit, String title) {
     showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Habit?"),
        content: Text("Delete '$title'?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              final date = ref.read(selectedDateProvider);
              ref.read(habitNotifierProvider.notifier).deleteHabit( habit, date);
              Navigator.pop(context);
            }, 
            child: const Text("Delete", style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );
  }
}