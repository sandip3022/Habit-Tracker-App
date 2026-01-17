import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/logic/progress_calculator.dart';

class ProgressBarChart extends StatelessWidget {
  final List<DailyProgress> data;

  const ProgressBarChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    const double chartHeight = 150.0; // Fixed height for the BARS only

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          // --- TOP ROW: Y-Axis & Bars ---
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Rotated Y-Axis Label
              RotatedBox(
                quarterTurns: -1,
                child: Text(
                  "Percent of Completion",
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // 2. Y-Axis Scale (Labels aligned to the 150px height)
              SizedBox(
                height: chartHeight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildYLabel("100"),
                    _buildYLabel("75"),
                    _buildYLabel("50"),
                    _buildYLabel("25"),
                    _buildYLabel("0"),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // 3. The Chart Area
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: data.asMap().entries.map((entry) {
                    final index = entry.key;
                    final day = entry.value;

                    return Flexible(
                      child: Column(
                        mainAxisSize: MainAxisSize.min, // Hug content
                        children: [
                          // --- THE BAR (Fixed Constraint) ---
                          // This container ensures the bar area is exactly 150px
                          // Bars grow from the bottom up inside this box.
                          SizedBox(
                            height: chartHeight,
                            child: Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                Tooltip(
                                  message: "${DateFormat('MMM d').format(day.date)}: ${(day.percentage * 100).toInt()}%",
                                  child: Container(
                                    width: 6,
                                    height: chartHeight * day.percentage, // 100% = 150px
                                    decoration: BoxDecoration(
                                      color: _getBarColor(day.percentage),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 8),
                          // --- X-AXIS LABEL ---
                          // Show label every 5th day
                          if ((data.length - 1 - index) % 5 == 0)
                            Text(
                              DateFormat('d').format(day.date),
                              style: TextStyle(fontSize: 7, color: AppColors.textSecondary),
                            )
                          else
                            const SizedBox(height: 12), // Placeholder for alignment
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // --- BOTTOM LABEL ---
          Text(
            "Days",
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYLabel(String text) {
    return Text(
      text,
      style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
    );
  }

  Color _getBarColor(double percentage) {
    if (percentage == 1.0) return AppColors.secondary; // Perfect
    if (percentage == 0.0) return Colors.grey[300]!;   // Missed
    return AppColors.primary.withValues(alpha: 0.6);   // Partial
  }
}