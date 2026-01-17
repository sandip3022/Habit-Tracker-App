import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For the date
import '../../../../core/theme/app_colors.dart'; 

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String userName;
  final String userAvatarUrl; // Optional: For future profile pic
  final VoidCallback onTimerTap; // Action for the timer icon

  const HomeAppBar({
    super.key,
    this.userName = "Sandip",
    this.userAvatarUrl = "", 
    required this.onTimerTap,
  });

  @override
  Widget build(BuildContext context) {
    // Get current date for the "Journal" feel
    final String dateText = DateFormat('EEEE, MMM d').format(DateTime.now()).toUpperCase();
    final textTheme = Theme.of(context).textTheme;

    return AppBar(
      backgroundColor: AppColors.background, // Blends with body
      elevation: 0,
      toolbarHeight: 80, // Taller header for better spacing
      automaticallyImplyLeading: false, // Remove default back arrow
      
      title: Padding(
        padding: const EdgeInsets.only(left: 8.0, top: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. SMALL GREETING / DATE
            Text(
              dateText, // e.g. "FRIDAY, OCT 24"
              style: textTheme.labelSmall?.copyWith(
                color: AppColors.textSecondary,
                letterSpacing: 1.5,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
            
            const SizedBox(height: 4),
            
            // 2. MAIN HEADING (Serif Font)
            Text(
              "${getSalutation()}, $userName",
              style: textTheme.displayMedium?.copyWith(
                fontSize: 28, // Big and bold
                color: AppColors.textPrimary,
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
      
      actions: [
        // 3. ACTION BUTTON (Timer)
        // Wrapped in a Container to look like a "Tool"
        Padding(
          padding: const EdgeInsets.only(right: 20.0, top: 10.0),
          child: GestureDetector(
            onTap: onTimerTap,
            child: Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: AppColors.surface, // White box
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.textSecondary.withValues(alpha: 0.1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Icon(
                Icons.timer_outlined, // Cleaner icon than the heavy box
                color: AppColors.primary,
                size: 24,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String getSalutation() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return "Good Morning";
    } else if (hour < 17) {
      return "Good Afternoon";
    } else {
      return "Good Evening";
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(80);
}