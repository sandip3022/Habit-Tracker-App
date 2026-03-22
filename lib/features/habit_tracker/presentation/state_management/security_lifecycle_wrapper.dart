import 'dart:developer';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker_app_2026/features/onboarding/presentation/pages/login_screen.dart';
import 'package:habit_tracker_app_2026/features/habit_tracker/presentation/state_management/privacy_provider.dart';

class SecurityLifecycleWrapper extends ConsumerStatefulWidget {
  final Widget child;

  const SecurityLifecycleWrapper({super.key, required this.child});

  @override
  ConsumerState<SecurityLifecycleWrapper> createState() =>
      _SecurityLifecycleWrapperState();
}

class _SecurityLifecycleWrapperState
    extends ConsumerState<SecurityLifecycleWrapper>
    with WidgetsBindingObserver {
  DateTime? _backgroundTime;
  bool _isBlurred = false;

  final Duration _timeoutDuration = const Duration(seconds: 10);

  @override
  void initState() {
    super.initState();
    // Start listening to the device's app lifecycle (background/foreground)
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // Stop listening when destroyed
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    log("Lifecycle: $state");

    final privacyState = ref.read(privacyProvider);
    final hasSecurityEnabled =
        privacyState.isPinEnabled || privacyState.isBiometricEnabled;

    if (!hasSecurityEnabled) return;

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.paused) {
      if (_backgroundTime == null) {
        _backgroundTime = DateTime.now();
      }

      setState(() {
        _isBlurred = true;
      });
    } else if (state == AppLifecycleState.resumed) {
      if (_backgroundTime != null) {
        final diff = DateTime.now().difference(_backgroundTime!);

        if (diff > _timeoutDuration) {
          Future.microtask(() {
            ref.read(privacyProvider.notifier).lockApp();
          });
        }
      }

      setState(() {
        _isBlurred = false;
      });

      _backgroundTime = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final privacyState = ref.watch(privacyProvider);
    final colorScheme = Theme.of(context).colorScheme;

    final bool hasSecurityEnabled =
        privacyState.isPinEnabled || privacyState.isBiometricEnabled;

    // The app is "locked" if they have security enabled, but auth is currently false
    final bool isLocked = hasSecurityEnabled && !privacyState.isAuthenicated;

    // We blur the screen if security is enabled AND the app is in the app switcher or background
    final bool shouldBlur = _isBlurred;

    return Stack(
      children: [
        // --- 1. THE MAIN CONTENT ---
        // SECURITY FEATURE: Conditional rendering is much safer than Navigator routing.
        // If the app is locked, the actual app UI doesn't even exist in memory.
        isLocked ? const LoginScreen() : widget.child,

        // --- 2. THE APP SWITCHER BLUR ---
        if (shouldBlur)
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                color: Theme.of(
                  context,
                ).scaffoldBackgroundColor.withValues(alpha: 0.6),
                child: Center(
                  child: Icon(
                    Icons.lock_outline,
                    size: 80,
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
