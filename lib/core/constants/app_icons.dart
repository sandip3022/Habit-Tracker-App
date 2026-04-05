import 'package:flutter/material.dart';

class AppIcons {
  static const Map<int, IconData> _registry = {
    57997: Icons.fitness_center,
    58333: Icons.menu_book,
    58674: Icons.restaurant,
    58735: Icons.self_improvement,
    984310: Icons.edit_note,
    57563: Icons.bedtime,
    984482: Icons.water_drop,
    57820: Icons.directions_run,
    57522: Icons.attach_money,
    57535: Icons.auto_stories,
    57718: Icons.code,
    57559: Icons.bed,
    58707: Icons.savings,
    58475: Icons.palette,
    58389: Icons.music_note,
    57689: Icons.check_circle,
  };

  // 2. Safe Retrieval Method
  static IconData getIcon(int codePoint) {
    return _registry[codePoint] ?? Icons.star_rounded;
  }

  static List<IconData> get allIcons => _registry.values.toList();
  static List<int> get allCodes => _registry.keys.toList();
}
