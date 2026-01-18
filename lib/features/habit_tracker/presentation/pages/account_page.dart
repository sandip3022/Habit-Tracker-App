import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker_app_2026/features/habit_tracker/presentation/pages/privacy_lock_page.dart';
import 'package:habit_tracker_app_2026/main.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_provider.dart';

class AccountPage extends ConsumerStatefulWidget {
  const AccountPage({super.key});

  @override
  ConsumerState<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends ConsumerState<AccountPage> {
  final String _userName = "Manoj Rav"; 
  bool _isNotificationOn = true;

  @override
  Widget build(BuildContext context) {
    // 1. WATCH THE THEME PROVIDER
    final currentTheme = ref.watch(themeProvider);
    final isDarkMode = currentTheme == ThemeMode.dark;
    
    // Access dynamic theme colors
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      // REMOVED: backgroundColor: AppColors.background (Let Theme handle it)
      appBar: AppBar(
        title: Text("Account", style: textTheme.displayMedium?.copyWith(fontSize: 24)),
        // REMOVED: backgroundColor: AppColors.background
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // --- 1. PROFILE SECTION ---
            _buildProfileSection(textTheme, colorScheme),
            
            const SizedBox(height: 40),

            // --- 2. SETTINGS LIST ---
            _buildSettingsCard(
              context,
              title: "Notifications",
              icon: Icons.notifications_outlined,
              trailing: Switch(
                value: _isNotificationOn,
                activeColor: AppColors.secondary,
                onChanged: (val) => setState(() => _isNotificationOn = val),
              ),
            ),
            
            const SizedBox(height: 16),

            // DARK MODE SWITCH
            _buildSettingsCard(
              context,
              title: "Dark Mode",
              icon: Icons.dark_mode_outlined,
              trailing: Switch(
                value: isDarkMode,
                activeColor: AppColors.secondary,
                onChanged: (val) {
                  ref.read(themeProvider.notifier).toggleTheme(val);
                },
              ),
            ),

            const SizedBox(height: 16),

            _buildSettingsCard(
              context,
              title: "Privacy Lock",
              icon: Icons.lock_outline,
              trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              onTap: () {
                // Navigate to Privacy Lock Page
                Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyLockPage()));
              },
            ),

            const SizedBox(height: 40),

            // --- 3. DANGER ZONE ---
            Text("DATA MANAGEMENT", 
              style: textTheme.labelSmall?.copyWith(
                color: isDarkMode ? Colors.grey : AppColors.textSecondary, // Dynamic Color
                letterSpacing: 1.2
              )
            ),
            const SizedBox(height: 16),

            _buildDestructiveCard(
              context,
              title: "Reset Progress",
              subtitle: "Keep habits, clear history",
              buttonLabel: "RESET",
              onTap: () => _showConfirmationSheet(
                context: context,
                title: "Reset all progress?",
                message: "This will remove all your streaks and completion history.",
                confirmLabel: "Reset",
                onConfirm: () {
                  ref.read(habitNotifierProvider.notifier).resetAllProgress();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Progress reset successfully")));
                },
              ),
            ),

            const SizedBox(height: 16),

            _buildDestructiveCard(
              context,
              title: "Delete Everything",
              subtitle: "Remove all habits & data",
              buttonLabel: "DELETE",
              isCritical: true, 
              onTap: () => _showConfirmationSheet(
                context: context,
                title: "Delete everything?",
                message: "This action cannot be undone.",
                confirmLabel: "Delete All",
                isCritical: true,
                onConfirm: () {
                  ref.read(habitNotifierProvider.notifier).deleteAllData();
                  Navigator.pop(context);
                  Navigator.pop(context); // Go back to Home
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("All data deleted")));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- UPDATED WIDGETS ---

  Widget _buildProfileSection(TextTheme textTheme, ColorScheme colorScheme) {
    return Column(
      children: [
        // 1. Circle Avatar with Initials
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.secondary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3), width: 2),
          ),
          alignment: Alignment.center,
          child: Text(
            _getInitials(_userName),
            style: textTheme.displayMedium?.copyWith(
              color: AppColors.secondary, 
              fontSize: 32
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _userName,
          // Use 'onSurface' so it is Black in Light Mode, White in Dark Mode
          style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onSurface),
        ),
        const SizedBox(height: 4),
        Text(
          "Free Member",
          style: textTheme.bodyMedium?.copyWith(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildSettingsCard(BuildContext context, {
    required String title, 
    required IconData icon, 
    Widget? trailing, 
    VoidCallback? onTap
  }) {
    // Access Theme Colors
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface, // <--- Dynamic Surface Color (White vs Slate)
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1), // Keep brand tint
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: colorScheme.onSurface)), // Dynamic Text
        trailing: trailing,
      ),
    );
  }

  Widget _buildDestructiveCard(BuildContext context, {
    required String title,
    required String subtitle,
    required String buttonLabel,
    required VoidCallback onTap,
    bool isCritical = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface, // <--- Dynamic Surface
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface, fontSize: 16)),
              const SizedBox(height: 4),
              Text(subtitle, style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          TextButton(
            onPressed: onTap,
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
              backgroundColor: isCritical ? Colors.red.withValues(alpha: 0.1) : Colors.transparent,
              side: isCritical ? null : const BorderSide(color: Colors.red),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(buttonLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  // ... (Helpers _getInitials and _showConfirmationSheet remain similar but ensure Sheet uses Theme colors too)
  String _getInitials(String name) {
    if (name.isEmpty) return "";
    List<String> nameParts = name.trim().split(" ");
    if (nameParts.length > 1) {
      // First letter of First Name + First letter of Last Name
      return "${nameParts[0][0]}${nameParts[1][0]}".toUpperCase();
    } else {
      // Just First letter
      return nameParts[0][0].toUpperCase();
    }
  }

  void _showConfirmationSheet({
    required BuildContext context,
    required String title,
    required String message,
    required String confirmLabel,
    required VoidCallback onConfirm,
    bool isCritical = false,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor, // Dynamic Sheet BG
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
             // ... content using Theme.of(context).textTheme ...
             Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
             // ...
             // (Copy rest of logic from previous step, ensuring colors are dynamic)
             // Shortened for brevity:
             const SizedBox(height: 32),
             Row(
               children: [
                 Expanded(child: OutlinedButton(onPressed: ()=>Navigator.pop(context), child: const Text("Cancel"))),
                 const SizedBox(width: 16),
                 Expanded(child: ElevatedButton(
                   onPressed: onConfirm, 
                   style: ElevatedButton.styleFrom(backgroundColor: isCritical? Colors.red : AppColors.primary),
                   child: Text(confirmLabel, style: const TextStyle(color: Colors.white))
                 )),
               ],
             )
          ],
        ),
      ),
    );
  }
}