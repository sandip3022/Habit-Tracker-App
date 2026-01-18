import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

class UserState {
  final String name;
  final bool isOnboardingCompleted;

  UserState({required this.name, required this.isOnboardingCompleted});
}

class UserNotifier extends StateNotifier<UserState> {
  UserNotifier() : super(UserState(name: '', isOnboardingCompleted: false)) {
    _loadUser();
  }

  void _loadUser() {
    final box = Hive.box('settings');
    final name = box.get('userName', defaultValue: '') as String;
    final completed = box.get('onboardingCompleted', defaultValue: false) as bool;
    state = UserState(name: name, isOnboardingCompleted: completed);
  }

  Future<void> setName(String name) async {
    final box = Hive.box('settings');
    await box.put('userName', name);
    state = UserState(name: name, isOnboardingCompleted: state.isOnboardingCompleted);
  }

  Future<void> completeOnboarding() async {
    final box = Hive.box('settings');
    await box.put('onboardingCompleted', true);
    state = UserState(name: state.name, isOnboardingCompleted: true);
  }
}

final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  return UserNotifier();
});