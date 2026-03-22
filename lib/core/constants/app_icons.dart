import 'package:flutter/material.dart';

class AppIcons {

  static const Map<int, IconData> _registry = {
    0xe0b0: Icons.fitness_center, 
    0xe198: Icons.menu_book,
    0xeb43: Icons.restaurant,
    0xe318: Icons.self_improvement,
    0xe156: Icons.edit_note,
    0xf06b: Icons.bedtime,
    0xe630: Icons.water_drop,
    0xe1d5: Icons.directions_run,
    0xe043: Icons.attach_money,
  };

  // 2. Safe Retrieval Method
  static IconData getIcon(int codePoint) {
    return _registry[codePoint] ?? Icons.star_rounded; 
  }

  static List<IconData> get allIcons => _registry.values.toList();
  static List<int> get allCodes => _registry.keys.toList();
}