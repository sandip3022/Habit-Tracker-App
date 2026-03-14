import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/logic/progress_calculator.dart';

class ProgressBarChart extends StatelessWidget {
  final List<DailyProgress> data;

  const ProgressBarChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    const double chartHeight = 150.0;

    // 1. Get Theme Colors
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final labelColor = colorScheme.onSurface.withValues(
      alpha: 0.6,
    ); // Adaptive Grey

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface, // <--- Dynamic Surface
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // --- TOP ROW: Y-Axis & Bars ---
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Y-Axis Label
              RotatedBox(
                quarterTurns: -1,
                child: Text(
                  "percent_completion".tr(),
                  style: TextStyle(
                    fontSize: 10,
                    color: labelColor, // Dynamic
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Y-Axis Scale
              SizedBox(
                height: chartHeight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildYLabel("hundred".tr(), labelColor),
                    _buildYLabel("sevety_five".tr(), labelColor),
                    _buildYLabel("fifty".tr(), labelColor),
                    _buildYLabel("twenty_five".tr(), labelColor),
                    _buildYLabel("zero".tr(), labelColor),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // The Chart Area
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: data.asMap().entries.map((entry) {
                    final index = entry.key;
                    final day = entry.value;

                    return Flexible(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // THE BAR
                          SizedBox(
                            height: chartHeight,
                            child: Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                Tooltip(
                                  message:
                                      "${DateFormat('MMM d').format(day.date)}: ${(day.percentage * 100).toInt()}%",
                                  child: Container(
                                    width: 6,
                                    height: chartHeight * day.percentage,
                                    decoration: BoxDecoration(
                                      // Pass isDark to helper to fix Grey bars
                                      color: _getBarColor(
                                        day.percentage,
                                        isDark,
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 8),

                          // X-AXIS LABEL
                          if ((data.length - 1 - index) % 5 == 0)
                            Text(
                              DateFormat('d').format(day.date),
                              style: TextStyle(fontSize: 10, color: labelColor),
                            )
                          else
                            const SizedBox(height: 12),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // BOTTOM LABEL
          Text(
            "days".tr(),
            style: TextStyle(
              fontSize: 11,
              color: labelColor,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYLabel(String text, Color color) {
    return Text(text, style: TextStyle(fontSize: 10, color: color));
  }

  Color _getBarColor(double percentage, bool isDark) {
    if (percentage == 1.0) return AppColors.secondary; // Perfect

    // Fix: In Dark Mode, Grey[300] is too bright. Use white10 (subtle grey).
    if (percentage == 0.0) return isDark ? Colors.white10 : Colors.grey[300]!;

    return AppColors.primary.withValues(alpha: 0.6); // Partial
  }
}
