import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker_app_2026/core/services/export_service.dart';
import 'package:habit_tracker_app_2026/core/services/import_service.dart';
import 'package:habit_tracker_app_2026/core/services/notification_service.dart';
import 'package:habit_tracker_app_2026/core/services/user_provider.dart';
import 'package:habit_tracker_app_2026/features/habit_tracker/presentation/pages/privacy_lock_page.dart';
import 'package:habit_tracker_app_2026/features/habit_tracker/presentation/state_management/privacy_provider.dart';
import 'package:habit_tracker_app_2026/features/onboarding/presentation/pages/login_screen.dart';
import 'package:habit_tracker_app_2026/main.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_provider.dart';

class AccountPage extends ConsumerStatefulWidget {
  const AccountPage({super.key});

  @override
  ConsumerState<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends ConsumerState<AccountPage> {
  bool _isNotificationOn = true;
  TimeOfDay? _reminderTime;

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  // Load saved state (You can also save 'reminderTime' string in Hive if you want persistence)
  void _loadNotificationSettings() {
    // For now, let's assume if Hive says it's on, we default to 9:00 AM or load from DB
    // Since we haven't set up Hive for this specific field yet, we stick to local state for demo
    // Ideally: _isNotificationOn = box.get('notify', defaultValue: false);
  }

  @override
  Widget build(BuildContext context) {
    // 1. WATCH THE THEME PROVIDER
    final currentTheme = ref.watch(themeProvider);
    final isDarkMode = currentTheme == ThemeMode.dark;
    final String _userName = ref.watch(userProvider);

    // Access dynamic theme colors
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      // REMOVED: backgroundColor: AppColors.background (Let Theme handle it)
      appBar: AppBar(
        title: Text(
          "account".tr(),
          style: textTheme.displayMedium?.copyWith(fontSize: 24),
        ),
        // REMOVED: backgroundColor: AppColors.background
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // --- 1. PROFILE SECTION ---
            _buildProfileSection(textTheme, colorScheme, _userName),

            const SizedBox(height: 40),

            // --- 2. SETTINGS LIST ---
            _buildSettingsCard(
              context,
              title: "daily_reminder".tr(),
              icon: Icons.notifications_outlined,
              trailing: ExcludeSemantics(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Show time if enabled
                    if (_isNotificationOn && _reminderTime != null)
                      Text(
                        _reminderTime!.format(context),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    Switch(
                      value: _isNotificationOn,
                      activeColor: AppColors.secondary,
                      onChanged: (val) => _toggleNotifications(val),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // DARK MODE SWITCH
            _buildSettingsCard(
              context,
              title: "dark_mode".tr(),
              icon: Icons.dark_mode_outlined,
              trailing: ExcludeSemantics(
                child: Switch(
                  value: isDarkMode,
                  activeColor: AppColors.secondary,
                  onChanged: (val) {
                    ref.read(themeProvider.notifier).toggleTheme(val);
                  },
                ),
              ),
            ),

            const SizedBox(height: 16),

            _buildSettingsCard(
              context,
              title: "language".tr(),
                   // Make sure to add "language" to your JSON files
              icon: Icons.language_outlined,
              trailing: ExcludeSemantics(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<Locale>(
                    // context.locale comes from easy_localization and holds the current language
                    value: context.locale,
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                    dropdownColor: colorScheme.surface,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                    onChanged: (Locale? newLocale) {
                      if (newLocale != null) {
                        // This instantly changes the app language and saves the preference!
                        context.setLocale(newLocale);
                      }
                    },
                    items: const [
                      DropdownMenuItem(
                        value: Locale('en'),
                        child: Text("English"),
                      ),
                      DropdownMenuItem(
                        value: Locale('mr'), // Official locale code for Marathi
                        child: Text("मराठी"),
                      ),
                      DropdownMenuItem(
                        value: Locale('hi'), // Official locale code for Hindi
                        child: Text("हिंदी"),
                      ),
                
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            _buildSettingsCard(
              context,
              title: "privacy_lock".tr(),
              icon: Icons.lock_outline,
              trailing: ExcludeSemantics(
                child: const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey,
                ),
              ),
              onTap: () {
                // Navigate to Privacy Lock Page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PrivacyLockPage()),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildSettingsCard(
              context,
              title: "export_to_csv".tr(),
              icon: Icons.download_outlined,
              trailing: ExcludeSemantics(
                child: const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey,
                ),
              ),
              onTap: () async {
                // 1. Get the current list of habits from the provider
                final currentHabits = ref.read(habitNotifierProvider).habits;

                if (currentHabits.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("No habits to export yet!")),
                  );
                  return;
                }

                // 2. Trigger the export
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Preparing your file...")),
                );

                try {
                  bool success = await ExportService.exportHabitsToCSV(
                    currentHabits,
                  );

                  // 👇 3. Show success message if they didn't cancel the dialog
                  if (success && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Export saved successfully!"),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Oops, export failed. Please try again."),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            ),
            const SizedBox(height: 16),
            _buildSettingsCard(
              context,
              title: "restore_from_backup".tr(),
              icon: Icons.upload_file_outlined,
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey,
              ),
              onTap: () async {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("select_backup_file".tr())),
                );

                try {
                  // 1. Open file picker and parse CSV
                  final importedHabits =
                      await ImportService.importHabitsFromCSV();

                  if (!context.mounted) return;

                  if (importedHabits == null) {
                    // User canceled the file picker
                    return;
                  }

                  if (importedHabits.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "invalid_backup_file".tr(),
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.orange,
                      ),
                    );
                    return;
                  }

                  // 2. Push data to database
                  await ref
                      .read(habitNotifierProvider.notifier)
                      .importHabits(importedHabits);

                  // 3. Success Feedback
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "successfully_restored_habits".tr(
                          args: [importedHabits.length.toString()],
                        ),
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(e.toString()),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            ),
            const SizedBox(height: 16),
            _buildSettingsCard(
              context,
              title: "log_out".tr(),
              icon: Icons.logout_outlined,
              trailing: ExcludeSemantics(
                child: const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey,
                ),
              ),
              onTap: () {
                  final privacyState = ref.read(privacyProvider);

                  if (privacyState.isPinEnabled || privacyState.isBiometricEnabled) {
                    // If any privacy lock is enabled, require authentication before logging out
                    ref.read(privacyProvider.notifier).lockApp();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("please_setup_security_first".tr()), // Make sure to add this to your JSON files
        backgroundColor: colorScheme.errorContainer,
      ),
    );
                  }

               
              },
            ),
            

            const SizedBox(height: 40),

            // --- 3. DANGER ZONE ---
            Text(
              "data_management".tr(),
              style: textTheme.labelSmall?.copyWith(
                color: isDarkMode
                    ? Colors.grey
                    : AppColors.textSecondary, // Dynamic Color
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 16),

            _buildDestructiveCard(
              context,
              title: "reset_progress".tr(),
              subtitle: "keep_habits_but_clear_history".tr(),
              buttonLabel: "resetCap".tr(),
              onTap: () => _showConfirmationSheet(
                context: context,
                title: "reset_all_progress".tr(),
                message: "reset_all_progress_message".tr(),
                confirmLabel: "reset".tr(),
                onConfirm: () {
                  ref.read(habitNotifierProvider.notifier).resetAllProgress();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("progress_reset_successfully".tr())),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            _buildDestructiveCard(
              context,
              title: "delete_everything".tr(),
              subtitle: "delete_everything_message".tr(),
              buttonLabel: "delete".tr(),
              isCritical: true,
              onTap: () => _showConfirmationSheet(
                context: context,
                title: "delete_everything_question".tr(),
                message: "this_action_cannot_be_undone".tr(),
                confirmLabel: "delete_all".tr(),
                isCritical: true,
                onConfirm: () {
                  ref.read(habitNotifierProvider.notifier).deleteAllData();
                  Navigator.pop(context); // Go back to Home
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "All data deleted".tr(),
                        style: TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- UPDATED WIDGETS ---

  Widget _buildProfileSection(
    TextTheme textTheme,
    ColorScheme colorScheme,
    String _userName,
  ) {
    return Semantics(
      label: "user_profile".tr(args: [_userName, "free_member".tr()]), // Add to JSON: "User Profile: {}, {}"
      excludeSemantics: true,
      child: Column(
        children: [
          // 1. Circle Avatar with Initials
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.secondary.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              _getInitials(_userName),
              style: textTheme.displayMedium?.copyWith(
                color: AppColors.secondary,
                fontSize: 32,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _userName,
            // Use 'onSurface' so it is Black in Light Mode, White in Dark Mode
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "free_member".tr(),
            style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color:
            colorScheme.surface, 
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: MergeSemantics(
        child: ListTile(
          onTap: onTap,
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1), // Keep brand tint
              borderRadius: BorderRadius.circular(8),
            ),
            child: ExcludeSemantics(child: Icon(icon, color: colorScheme.onSurface)),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ), // Dynamic Text
          trailing: trailing,
        ),
      ),
    );
  }

  Widget _buildDestructiveCard(
    BuildContext context, {
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
          MergeSemantics(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onTap,
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
              backgroundColor: isCritical
                  ? Colors.red.withValues(alpha: 0.1)
                  : Colors.transparent,
              side: isCritical ? null : const BorderSide(color: Colors.red),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              buttonLabel,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

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
          color: Theme.of(context).scaffoldBackgroundColor, 
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            ExcludeSemantics(
              child: Icon(
                Icons.warning_amber_rounded,
                size: 48,
                color: isCritical ? Colors.red : Colors.orange,
              ),
            ),
            const SizedBox(height: 16),

            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: onConfirm,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: isCritical
                          ? Colors.red
                          : AppColors.primary,
                    ),
                    child: Text(
                      confirmLabel,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleNotifications(bool value) async {
    final service = NotificationService();

    if (value) {
      // 1. ENABLE: Request Permission First
      final bool granted = await service.requestPermissions();
      if (!granted) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Permission denied")));
        return;
      }

      // 2. Pick Time
      if (!mounted) return;
      final TimeOfDay? picked = await showTimePicker(
        context: context,
        initialTime: const TimeOfDay(hour: 9, minute: 0),
        builder: (context, child) {
          // Make TimePicker match Dark/Light theme
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return Theme(
            data: isDark
                ? ThemeData.dark()
                : ThemeData.light().copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: AppColors.primary,
                    ),
                  ),
            child: child!,
          );
        },
      );

      if (picked != null) {
        await service.scheduleDailyNotification(time: picked);
        setState(() {
          _isNotificationOn = true;
          _reminderTime = picked;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("reminder_set".tr(args: [picked.format(context)])),
          ),
        );
      }
    } else {
      // 3. DISABLE
      await service.cancelNotifications();
      setState(() {
        _isNotificationOn = false;
        _reminderTime = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("reminders_turned_off".tr())),
      ); // Updated text
    }
  }
}
