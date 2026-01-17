import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker_app_2026/features/habit_tracker/presentation/widgets/progress_bar_chart.dart';
import 'package:habit_tracker_app_2026/main.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/logic/progress_calculator.dart';

class ProgressPage extends ConsumerWidget {
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Get Data
    final habitState = ref.watch(habitNotifierProvider);
    // 2. Calculate Logic
    final stats = ProgressCalculator.calculate(habitState.habits);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text("Progress & Insights", style: textTheme.displayMedium?.copyWith(fontSize: 22)),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- ROW 1: 3 BOXES (Total, Active, Stalled) ---
            Row(
              children: [
                Expanded(child: _buildStatCard(context, "All Habits", "${stats.totalHabits}", Colors.blue)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard(context, "Active", "${stats.activeCount}", Colors.green)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard(context, "Stalled", "${stats.stalledCount}", Colors.orange)),
              ],
            ),

            const SizedBox(height: 24),

            // --- ROW 2: AVG COMPLETION RATE ---
            _buildWideStatCard(
              context, 
              "Avg. Completion Rate", 
              "${(stats.avgCompletionRate * 100).toStringAsFixed(1)}%",
              AppColors.primary
            ),

            const SizedBox(height: 24),

            // --- ROW 3: BAR CHART (30 Days) ---
            Text("LAST 30 DAYS", style: textTheme.labelSmall?.copyWith(color: AppColors.textSecondary, letterSpacing: 1.2)),
            const SizedBox(height: 12),
            ProgressBarChart(data: stats.last30Days),

            const SizedBox(height: 24),

            // --- ROW 4: PERFECT / PARTIAL / MISSED ---
            Row(
              children: [
                Expanded(child: _buildStatCard(context, "Perfect", "${stats.perfectDays}", Colors.teal)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard(context, "Partial", "${stats.partialDays}", Colors.amber)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard(context, "Missed", "${stats.missedDays}", Colors.redAccent)),
              ],
            ),

            const SizedBox(height: 32),

            // --- LIST: TOP HABITS (Sorted) ---
            Text("TOP PERFORMING HABITS", style: textTheme.labelSmall?.copyWith(color: AppColors.textSecondary, letterSpacing: 1.2)),
            const SizedBox(height: 12),
            ...stats.leaderboard.map((item) => _buildHabitSuccessTile(context, item)),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS ---

  Widget _buildStatCard(BuildContext context, String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 12, color: AppColors.textSecondary), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildWideStatCard(BuildContext context, String title, String value, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color, // Primary Color
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

 

  Widget _buildHabitSuccessTile(BuildContext context, HabitSuccessRate item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Color(item.habit.colorValue).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(IconData(item.habit.iconCode, fontFamily: 'MaterialIcons'), 
              color: Color(item.habit.colorValue), size: 20
            ),
          ),
          const SizedBox(width: 12),
          // Title
          Expanded(
            child: Text(item.habit.title, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          // Percentage
          Text(
            "${(item.rate * 100).toInt()}%",
            style: TextStyle(
              fontWeight: FontWeight.bold, 
              color: item.rate >= 0.8 ? Colors.green : (item.rate >= 0.5 ? Colors.orange : Colors.red)
            ),
          ),
        ],
      ),
    );
  }
}