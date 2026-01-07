import 'package:flutter/material.dart';
import '../../domain/entities/habit_entity.dart';

class HabitTile extends StatelessWidget {
  final HabitEntity habit;
  final bool isCompletedToday;
  final VoidCallback onToggle;
  final VoidCallback onTapBody; // Opens History
  final VoidCallback onEdit;    // NEW: Triggers Edit Sheet
  final VoidCallback onDelete;  // NEW: Triggers Delete Dialog

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
    // Convert int color to Color object
    final baseColor = Color(habit.colorValue);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Material(
        color: Colors.white,
        elevation: 2,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTapBody, 
          child: Container(
            padding: const EdgeInsets.all(12.0), // Reduced padding slightly for better density
            decoration: BoxDecoration(
              border: isCompletedToday 
                  ? Border.all(color: baseColor.withValues(alpha: 0.5), width: 2)
                  : null,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                // 1. Icon Box
                _buildIconBox(baseColor),
                
                const SizedBox(width: 16),

                // 2. Title Section (Expands to fill space)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        habit.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          decoration: isCompletedToday 
                              ? TextDecoration.lineThrough 
                              : null,
                          color: isCompletedToday ? Colors.grey : Colors.black87,
                        ),
                      ),
                      // Optional: Tiny date range or streak text can go here
                    ],
                  ),
                ),

                // 3. Check Button (The Primary Action)
                GestureDetector(
                  onTap: onToggle, 
                  child: _buildCheckButton(baseColor),
                ),

                const SizedBox(width: 4),

                // 4. More Options Menu (The "Edit/Delete" UX)
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
      height: 48, // Slightly more compact
      width: 48,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        IconData(habit.iconCode, fontFamily: 'MaterialIcons'),
        color: color,
        size: 24,
      ),
    );
  }

  Widget _buildCheckButton(Color color) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      height: 34,
      width: 34,
      decoration: BoxDecoration(
        color: isCompletedToday ? color : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: isCompletedToday ? color : Colors.grey.shade300,
          width: 2,
        ),
      ),
      child: isCompletedToday
          ? const Icon(Icons.check, size: 20, color: Colors.white)
          : null,
    );
  }

  Widget _buildOptionsMenu(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, color: Colors.grey[400]),
      color: const Color.fromARGB(255, 4, 158, 229),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (value) {
        if (value == 'edit') {
          onEdit();
        } else if (value == 'delete') {
          onDelete();
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit, size: 20, color: Colors.white70),
              SizedBox(width: 12),
              Text('Edit'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem<String>(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, size: 20, color: Colors.red),
              SizedBox(width: 12),
              Text('Delete', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    );
  }
}