import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

class UserNotifier extends StateNotifier<String> {
  // Initialize by loading the name from Hive..
  UserNotifier() : super(_loadInitialName());

  static String _loadInitialName() {
    final box = Hive.box('settings');
    return box.get('userName', defaultValue: 'Guest'); 
  }

  Future<void> setName(String newName) async {
    final cleanName = newName.trim();
    if (cleanName.isNotEmpty) {
      state = cleanName; 
      final box = Hive.box('settings');
      await box.put('userName', cleanName); 
    }
  }
}

final userProvider = StateNotifierProvider<UserNotifier, String>((ref) {
  return UserNotifier();
});