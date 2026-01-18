

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

class ThemeNotifier  extends StateNotifier<ThemeMode>{
  ThemeNotifier(): super(ThemeMode.system){
    _loadTheme();
  }


  void _loadTheme(){
    final box = Hive.box('settings');
    final isDark = box.get('isDarkMode',defaultValue: false);
    state = isDark ? ThemeMode.dark : ThemeMode.light;
    
  }

  void toggleTheme(bool isDark){
    final box = Hive.box('settings');
    box.put('isDarkMode', isDark);
    state = isDark ? ThemeMode.dark : ThemeMode.light;
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((refs){
  return ThemeNotifier();
});