import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker_app_2026/features/habit_tracker/presentation/pages/home_page.dart';
import 'package:habit_tracker_app_2026/features/habit_tracker/presentation/pages/pin_screen.dart';
import 'package:habit_tracker_app_2026/features/habit_tracker/presentation/state_management/privacy_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  @override
  void initState() {
    super.initState();
    // Try biometric immediately on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkBiometric();
    });
  }

  Future<void> _checkBiometric() async {
    final notifier = ref.read(privacyProvider.notifier);
    final state = ref.read(privacyProvider);

    if (state.isBiometricEnabled) {
      await notifier.authenticateuser();
      if (ref.read(privacyProvider).isAuthenicated) {
        _unlock();
      }
    }
  }

  void _unlock() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final privacyState = ref.watch(privacyProvider);
    final colorScheme = Theme.of(context).colorScheme;

    // If User has PIN enabled, show the keypad directly in this screen
    if (privacyState.isPinEnabled) {
      return PinScreen(
        mode: PinMode.verify,
        title: "welcome_back".tr(),
        onSuccess: (_) => _unlock(),
      );
    }

    // If Only Biometric is enabled (rare case if PIN is usually fallback)
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Icon(Icons.fingerprint, size: 80, color: colorScheme.primary),
            const SizedBox(height: 20),
            Text(
              "locked".tr(),
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _checkBiometric,
              child: const Text("unlock_with_faceid_fingerprint").tr(),
            ),
          ],
        ),
      ),
    );
  }
}
