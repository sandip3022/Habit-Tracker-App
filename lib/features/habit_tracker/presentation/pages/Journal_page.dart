import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:habit_tracker_app_2026/features/habit_tracker/domain/entities/habit_entity.dart';
import 'package:habit_tracker_app_2026/features/habit_tracker/presentation/pages/add_habit_page.dart';
import 'package:habit_tracker_app_2026/features/habit_tracker/presentation/pages/habit_history_page.dart';
import 'package:habit_tracker_app_2026/features/habit_tracker/presentation/state_management/habit_provider.dart';
import 'package:habit_tracker_app_2026/features/habit_tracker/presentation/widgets/app_bar.dart';
import 'package:habit_tracker_app_2026/features/habit_tracker/presentation/widgets/date_selector.dart';
import 'package:habit_tracker_app_2026/features/habit_tracker/presentation/widgets/habit_tile.dart';
import 'package:habit_tracker_app_2026/features/onboarding/presentation/state_management/user_provider.dart';
import 'package:habit_tracker_app_2026/features/timer/presentation/timer_home.dart';
import 'package:habit_tracker_app_2026/main.dart';

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
    final userName = ref.watch(userProvider);
    return Scaffold(
      appBar: HomeAppBar(
        userName: userName.name,
        onTimerTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TimerHome()),
          );
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            // --- 1. DATE NAVIGATOR ---
            DateSelector(
              selectedDate: selectedDate,
              onPrevious: () => _changeDate(-1),
              onNext: () => _changeDate(1),
            ),

            const SizedBox(height: 10),

            // --- 3. HABIT LIST ---
            Expanded(
              child: habitState.habits.isEmpty
                  ? _buildEmptyState()
                  : ReorderableListView.builder(
                      shrinkWrap: true,
                      physics:
                          const NeverScrollableScrollPhysics(), // If inside a ScrollView
                      itemCount: habitState.habits.length,

                      // 1. The Drag and Drop trigger
                      onReorder: (oldIndex, newIndex) {
                        ref
                            .read(habitNotifierProvider.notifier)
                            .reorderHabits(oldIndex, newIndex);
                        // Optional: Add a tiny haptic buzz when dropped!
                        HapticFeedback.lightImpact();
                      },

                      // 2. Keep the dragged item looking clean (matches your Modern Journal theme)
                      proxyDecorator:
                          (
                            Widget child,
                            int index,
                            Animation<double> animation,
                          ) {
                            return Material(
                              color: Colors.transparent,
                              elevation: 0,
                              child: child,
                            );
                          },

                      itemBuilder: (context, index) {
                        final habit = habitState.habits[index];

                        // 3. CRITICAL: Reorderable items MUST have a unique Key
                        return Container(
                          key: ValueKey(habit.id),
                          child: HabitTile(
                            habit: habit,
                            isCompletedToday: habit.isCompletedOn(selectedDate),
                            onToggle: () {
                              // Pass selectedDate so we toggle the correct day!
                              ref
                                  .read(habitNotifierProvider.notifier)
                                  .toggle(habit, selectedDate);
                            },
                            onLongPressBody: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      HabitHistoryPage(habit: habit),
                                ),
                              );
                            },
                            onEdit: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      AddHabitPage(habitToEdit: habit),
                                ),
                              );
                            },
                            onDelete: () {
                              _showDeleteConfirmation(
                                context,
                                habit,
                                habit.title,
                              );
                            },
                          ),
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
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddHabitPage()),
          );
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
          Text(
            "No habits for this day",
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    HabitEntity habit,
    String title,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Habit?"),
        content: Text("Delete '$title'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              final date = ref.read(selectedDateProvider);
              ref.read(habitNotifierProvider.notifier).deleteHabit(habit, date);
              Navigator.pop(context);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
