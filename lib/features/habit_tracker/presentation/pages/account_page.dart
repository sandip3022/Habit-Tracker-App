import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker_app_2026/features/habit_tracker/presentation/pages/privacy_lock_page.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:habit_tracker_app_2026/main.dart';

// import 'privacy_lock_page.dart'; // Create this file later or comment out for now

class AccountPage extends ConsumerStatefulWidget {
  const AccountPage({super.key});

  @override
  ConsumerState<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends ConsumerState<AccountPage> {
  // Mock User Data (Replace with real data later)
  final String _userName = "Sandip Anap"; 
  bool _isNotificationOn = true;
  bool _isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text("Account", style: textTheme.displayMedium?.copyWith(fontSize: 24)),
        backgroundColor: AppColors.background,
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // --- 1. PROFILE SECTION ---
            _buildProfileSection(textTheme),
            
            const SizedBox(height: 40),

            // --- 2. SETTINGS LIST ---
            _buildSettingsCard(
              title: "Notifications",
              icon: Icons.notifications_outlined,
              trailing: Switch(
                value: _isNotificationOn,
                activeThumbColor: AppColors.primary,
                onChanged: (val) => setState(() => _isNotificationOn = val),
              ),
            ),
            
            const SizedBox(height: 16),

            _buildSettingsCard(
              title: "Dark Mode",
              icon: Icons.dark_mode_outlined,
              trailing: Switch(
                value: _isDarkMode,
                activeThumbColor: AppColors.primary,
                onChanged: (val) => setState(() => _isDarkMode = val),
              ),
            ),

            const SizedBox(height: 16),

            _buildSettingsCard(
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
              style: textTheme.labelSmall?.copyWith(color: AppColors.textSecondary, letterSpacing: 1.2)
            ),
            const SizedBox(height: 16),

            // 6. Reset Data
            _buildDestructiveCard(
              context,
              title: "Reset Progress",
              subtitle: "Keep habits, clear history",
              buttonLabel: "RESET",
              onTap: () => _showConfirmationSheet(
                context: context,
                title: "Reset all progress?",
                message: "This will remove all your streaks and completion history. Your habits will remain.",
                confirmLabel: "Reset",
                onConfirm: () {
                  ref.read(habitNotifierProvider.notifier).resetAllProgress();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Progress reset successfully")));
                },
              ),
            ),

            const SizedBox(height: 16),

            // 7. Delete All Data
            _buildDestructiveCard(
              context,
              title: "Delete Everything",
              subtitle: "Remove all habits & data",
              buttonLabel: "DELETE",
              isCritical: true, // Makes button filled red for extra warning
              onTap: () => _showConfirmationSheet(
                context: context,
                title: "Delete everything?",
                message: "This action cannot be undone. All habits, streaks, and settings will be permanently lost.",
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

  // --- WIDGETS ---

  Widget _buildProfileSection(TextTheme textTheme) {
    return Column(
      children: [
        // 1. Circle Avatar with Initials
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.secondary.withValues(alpha: 0.1), // Soft Coral Tint
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
        // 2. Name
        Text(
          _userName,
          style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 4),
        Text(
          "Free Member",
          style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildSettingsCard({
    required String title, 
    required IconData icon, 
    Widget? trailing, 
    VoidCallback? onTap
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Column: Title & Subtitle
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 16)),
              const SizedBox(height: 4),
              Text(subtitle, style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            ],
          ),
          
          // Button: Outlined Red
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

  // --- LOGIC HELPERS ---

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
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, color: Colors.grey[300], margin: const EdgeInsets.only(bottom: 24)),
            
            Icon(Icons.warning_amber_rounded, size: 48, color: isCritical ? Colors.red : Colors.orange),
            const SizedBox(height: 16),
            
            Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            
            Text(message, textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 32),
            
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isCritical ? Colors.red : AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(confirmLabel, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}