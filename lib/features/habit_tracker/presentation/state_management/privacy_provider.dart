import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

class PrivacyState {
  final bool isBiometricEnabled;
  final bool isPinEnabled;
  final bool isAuthenicated;
  final bool isBlurred;

  PrivacyState({
    this.isBiometricEnabled = false,
    this.isPinEnabled = false,
    this.isAuthenicated = false,
    this.isBlurred = false,
  });

  PrivacyState copyWith({bool? bio, bool? pin, bool? auth, bool? blurred}) {
    return PrivacyState(
      isBiometricEnabled: bio ?? isBiometricEnabled,
      isPinEnabled: pin ?? isPinEnabled,
      isAuthenicated: auth ?? isAuthenicated,
      isBlurred: blurred ?? isBlurred,
    );
  }
}

class PrivacyNotifier extends StateNotifier<PrivacyState> {
  final _storage = const FlutterSecureStorage();
  final _auth = LocalAuthentication();

  PrivacyNotifier() : super(PrivacyState()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    String? bio = await _storage.read(key: 'biometric_enabled');
    String? pin = await _storage.read(key: 'user_pin');

    state = state.copyWith(pin: pin != null, bio: bio == 'true');
  }

  Future<void> setPin(String pin) async {
    await _storage.write(key: 'user_pin', value: pin);
    state = state.copyWith(pin: true);
  }

  Future<void> removePin() async {
    await _storage.delete(key: 'user_pin');
    state = state.copyWith(pin: false);
  }

  Future<bool> verifyPin(String inputPin) async {
    String? storedPin = await _storage.read(key: 'user_pin');
    if (storedPin == inputPin) {
      state = state.copyWith(auth: true);
      return true;
    }
    return false;
  }

  Future<void> authenticateuser() async {
    if (state.isBiometricEnabled) {
      try {
        bool didAuth = await _auth.authenticate(
          localizedReason: 'Unlock Habit Tracker',
          options: const AuthenticationOptions(stickyAuth: true),
        );
        state = state.copyWith(auth: didAuth);
      } catch (e) {
        state = state.copyWith(auth: false);
      }
    }
  }

  Future<void> toggleBiometric(bool newValue) async {
    // 1. Check if device supports biometrics first
    final bool canAuthenticate =
        await _auth.canCheckBiometrics || await _auth.isDeviceSupported();
    if (!canAuthenticate) {
      // Hardware not available
      return;
    }

    // 2. Define the security prompt message
    final String reason = newValue
        ? 'Authenticate to ENABLE Biometric Lock'
        : 'Authenticate to DISABLE Biometric Lock';

    try {
      // 3. Trigger the Pop-up
      final bool didAuthenticate = await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      // 4. Only update settings if Authentication passed
      if (didAuthenticate) {
        if (newValue) {
          // Enable
          await _storage.write(key: 'biometric_enabled', value: 'true');
          state = state.copyWith(bio: true);
        } else {
          // Disable
          await _storage.delete(key: 'biometric_enabled');
          state = state.copyWith(bio: false);
        }
      }
    } catch (e) {
      log("Biometric Error: $e");
    }
  }

  void lockApp() {
    state = state.copyWith(auth: false);
  }

  void setBlur(bool value) {
    state = state.copyWith(blurred: value);
  }
}

final privacyProvider = StateNotifierProvider<PrivacyNotifier, PrivacyState>(
  (ref) => PrivacyNotifier(),
);
