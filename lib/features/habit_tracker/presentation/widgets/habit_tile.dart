import 'package:flutter/material.dart';
import '../../domain/entities/habit_entity.dart';
import '../../../../core/theme/app_colors.dart';

class HabitTile extends StatelessWidget {
  final HabitEntity habit;
  final bool isCompletedToday;
  final VoidCallback onToggle;
  final VoidCallback onTapBody;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const HabitTile({
    super.key,
    required this.habit,
    required this.isCompletedToday,
    required this.onToggle,
    required this.onTapBody,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Get the base color (User selected color)
    final habitColor = Color(habit.colorValue);

    // 2. Access Theme Data
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: AppColors.surface, // Use the Theme Surface (White)
        borderRadius: BorderRadius.circular(16),

        border: isCompletedToday
            ? Border.all(color: habitColor.withValues(alpha: 0.5), width: 2)
            : null,

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.05,
            ), // Very subtle modern shadow
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTapBody,
          child: Padding(
            padding: const EdgeInsets.all(
              16.0,
            ), // Generous padding for a "clean" look
            child: Row(
              children: [
                // --- 1. THEMED ICON BOX ---
                _buildIconBox(habitColor),

                const SizedBox(width: 16),

                // --- 2. TITLE & STREAK INFO ---
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title using the "Serif" font from your Theme
                      Text(
                        habit.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          decoration: isCompletedToday
                              ? TextDecoration.lineThrough
                              : null,
                          color: isCompletedToday
                              ? AppColors.textSecondary.withValues(alpha: 0.5)
                              : AppColors.textPrimary,
                        ),
                      ),

                      const SizedBox(height: 6),

                      // Streak Badge (Uses Secondary Color for "Action/Heat")
                      if (habit.currentStreak > 0)
                        Row(
                          children: [
                            Icon(
                              Icons.local_fire_department_rounded,
                              size: 14,
                              color: AppColors.secondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "${habit.currentStreak} Day Streak",
                              style: textTheme.labelSmall?.copyWith(
                                color: AppColors.secondary,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        )
                      else
                        Text(
                          "Start your journey today",
                          style: textTheme.bodySmall?.copyWith(fontSize: 12),
                        ),
                    ],
                  ),
                ),

                // --- 3. CHECK BUTTON (ACTION) ---
                GestureDetector(
                  onTap: onToggle,
                  child: _buildCheckButton(habitColor),
                ),

                const SizedBox(width: 8),

                // --- 4. MENU (EDIT/DELETE) ---
                _buildOptionsMenu(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconBox(Color color) {
    return Container(
      height: 50,
      width: 50,
      decoration: BoxDecoration(
        // Dynamic Tint: Uses 10% opacity of the habit's own color
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(
        IconData(habit.iconCode, fontFamily: 'MaterialIcons'),
        color: color, // Icon is full strength color
        size: 26,
      ),
    );
  }

  Widget _buildCheckButton(Color color) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutBack,
      height: 32,
      width: 32,
      decoration: BoxDecoration(
        // If completed, fill with color. If not, transparent with border.
        color: isCompletedToday ? color : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          // Border is Grey when unchecked, Color when checked
          color: isCompletedToday
              ? color
              : AppColors.textSecondary.withValues(alpha: 0.3),
          width: 2.5,
        ),
      ),
      child: isCompletedToday
          ? const Icon(Icons.check, size: 20, color: Colors.white)
          : null,
    );
  }

  Widget _buildOptionsMenu(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert,
        color: AppColors.textSecondary.withValues(alpha: 0.5),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: AppColors.surface,
      elevation: 4,
      onSelected: (value) {
        if (value == 'edit') onEdit();
        if (value == 'delete') onDelete();
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'edit',
          child: Row(
            children: [
              const Icon(Icons.edit_outlined, size: 20),
              const SizedBox(width: 12),
              Text('Edit', style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline, size: 20, color: AppColors.error),
              const SizedBox(width: 12),
              Text(
                'Delete',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.error),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
