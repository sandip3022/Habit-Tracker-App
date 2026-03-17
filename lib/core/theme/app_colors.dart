import 'package:flutter/material.dart';

class AppColors {
  // 1. BASE COLORS
  static const Color primary = Color(0xFF2C3E50); // Midnight Navy
  static const Color primaryDark = Color(0xFF5D8AA8); // Air Force Blue
  static const Color secondary = Color(0xFFFF6B6B); // Soft Coral (Action)
  static const Color background = Color(0xFFF7F9FC); // Very light Grey-Blue

  static const Color darkBackground = Color(0xFF0F172A);
  static const Color surface = Colors.white;
  static const Color error = Color(0xFFE57373);
  static const Color darkSurface = Color(0xFF1E293B);

  // 2. TEXT COLORS
  static const Color textPrimary = Color(0xFF2D3436);
  static const Color textSecondary = Color(0xFF636E72);

  // Separated Error colors for Light/Dark contrast compliance
  static const Color errorLight = Color(0xFFD32F2F); // Darker red for White backgrounds
  static const Color errorDark = Color(0xFFE57373); // Soft red for Dark backgrounds

  // 3. TINT GENERATOR (Your Request)
  // Returns the color with specific opacity (e.g., 10%, 20%)
  static Color primaryTint10 = primary.withValues(alpha: 0.1);
  static Color primaryTint20 = primary.withValues(alpha: 0.2);

  static Color secondaryTint10 = secondary.withValues(alpha: 0.1);
  static Color secondaryTint20 = secondary.withValues(alpha: 0.2);
}
