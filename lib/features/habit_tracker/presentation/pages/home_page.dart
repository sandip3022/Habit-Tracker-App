import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker_app_2026/features/habit_tracker/domain/entities/habit_entity.dart';
import 'package:intl/intl.dart';

// Import necessary layers
import '../../../../main.dart'; // To access providers
import '../widgets/habit_tile.dart';
import 'add_habit_page.dart';
import 'habit_history_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    // Trigger initial data load when the page is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(habitNotifierProvider.notifier).loadHabits();
    });
  }

  @override
  Widget build(BuildContext context) {
    // 1. Watch the state (Rebuilds whenever habits change)
    final habitState = ref.watch(habitNotifierProvider);
    final allHabits = habitState.habits;

    // 2. Filter logic can also live here if purely UI-related,
    // or ideally inside the Notifier/UseCase.
    // For now, let's assume the Notifier gives us *all* habits,
    // and we filter for "Today" here to keep the Notifier simple.
    final today = DateTime.now();
    final todaysHabits = allHabits.where((h) {
      // Simple logic: If it's daily OR specific day matches today
      // (Note: In a robust app, use the Domain Entity method 'isScheduledFor')
      // We will assume the Entity has the helper method we wrote earlier.
      return h.isScheduledFor(today);
    }).toList();

    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: CustomScrollView(
        slivers: [
          // A. Custom App Bar
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            pinned: true,
            backgroundColor: Colors.grey[200],
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
              title: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Hello, Sandip", // Placeholder for User Name
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Your Habits",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              // Date Display
              Padding(
                padding: const EdgeInsets.only(right: 10.0, top: 5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      DateFormat('MMMM').format(today).toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      DateFormat('d').format(today),
                      style: const TextStyle(
                        fontSize: 24,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // B. Progress Indicator (Optional visual flair)
          SliverToBoxAdapter(child: _buildProgressHeader(todaysHabits, today)),

          // C. HabitModel List
          if (todaysHabits.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.spa, size: 64, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    Text(
                      "No habits for today.\nEnjoy your free time!",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final habit = todaysHabits[index];
                final isCompleted = habit.isCompletedOn(today);

                return HabitTile(
                  habit: habit,
                  isCompletedToday: isCompleted,
                  onToggle: () {
                    // Call the Notifier (State Management)
                    ref.read(habitNotifierProvider.notifier).toggle(habit);
                  },
                  onTapBody: () {
                    // Navigate to History/Details
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HabitHistoryPage(habit: habit),
                      ),
                    );
                  },
                  onDelete: () {
                    _showDeleteConfirmation(context, habit, habit.title);
                  },
                  onEdit: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddHabitPage(habit: habit),
                      ),
                    );
                  },
                );
              }, childCount: todaysHabits.length),
            ),

          // Add some bottom padding so the FAB doesn't cover the last item
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),

      // D. Floating Action Button
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.black,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("New HabitModel", style: TextStyle(color: Colors.white)),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddHabitPage()),
          ).then((_) {
            // Reload when coming back (though Riverpod stream should handle this,
            // it's good practice for manual refreshes if needed)
            ref.read(habitNotifierProvider.notifier).loadHabits();
          });
        },
      ),
    );
  }

  /// A small widget to show "3/5 Done" progress at the top
  Widget _buildProgressHeader(List<dynamic> todaysHabits, DateTime today) {
    if (todaysHabits.isEmpty) return const SizedBox.shrink();

    final completedCount = todaysHabits
        .where((h) => h.isCompletedOn(today))
        .length;
    final totalCount = todaysHabits.length;
    final progress = totalCount == 0 ? 0.0 : completedCount / totalCount;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade800, Colors.blue.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withValues(alpha: 0.5),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Keep it up!",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${(progress * 100).toInt()}% Completed",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 40,
              width: 40,
              child: CircularProgressIndicator(
                value: progress,
                backgroundColor: Colors.white24,
                color: Colors.white,
                strokeWidth: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    HabitEntity habit,
    String habitTitle,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete HabitModel?"),
        content: Text(
          "Are you sure you want to delete '$habitTitle'? This action cannot be undone.",
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Cancel
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              // 1. Call the Notifier to delete
              ref.read(habitNotifierProvider.notifier).deleteHabit(habit);

              // 2. Close dialog
              Navigator.pop(context);

              // 3. Show a snackbar feedback
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Deleted '$habitTitle'"),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              setState(() {
                
              });
            },
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
