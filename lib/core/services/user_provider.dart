import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

class UserNotifier extends StateNotifier<String> {
  // Initialize by loading the name from Hive. Default to "Guest" if not found.
  UserNotifier() : super(_loadInitialName());

  static String _loadInitialName() {
    final box = Hive.box('settings');
    // Look for 'userName'. If it doesn't exist yet, return 'Guest'
    return box.get('userName', defaultValue: 'Guest'); 
  }

  // Call this when the user enters their name in Onboarding or edits their profile
  Future<void> setName(String newName) async {
    final cleanName = newName.trim();
    if (cleanName.isNotEmpty) {
      state = cleanName; // Updates the UI instantly
      final box = Hive.box('settings');
      await box.put('userName', cleanName); // Saves permanently to database
    }
  }
}

// The provider you will watch in your widgets
final userProvider = StateNotifierProvider<UserNotifier, String>((ref) {
  return UserNotifier();
});