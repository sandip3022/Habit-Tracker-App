import 'package:flutter/material.dart';
import 'package:habit_tracker_app_2026/core/theme/app_colors.dart';


class BuildSettingsCard extends StatelessWidget {
    const BuildSettingsCard({
      super.key,
      required this.title,
      required this.icon,
      this.trailing, this.onTap,
    });

    final String title;
    final IconData icon;
    final Widget? trailing;
    final VoidCallback? onTap;

    @override
    Widget build(BuildContext context) {
      final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
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
              color: AppColors.primary.withValues(
                alpha: 0.1,
              ), // Keep brand tint
              borderRadius: BorderRadius.circular(8),
            ),
            child: ExcludeSemantics(
              child: Icon(icon, color: colorScheme.onSurface),
            ),
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
}

class BuildDestructiveCard extends StatelessWidget {
  const BuildDestructiveCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.onTap,
    this.isCritical = false,
  });

  final String title;
  final String subtitle;
  final String buttonLabel;
  final VoidCallback onTap;
  final bool isCritical;

  @override
  Widget build(BuildContext context) {
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
}
    