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

  final Duration _timeoutDuration = const Duration(minutes: 3);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
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
      _backgroundTime ??= DateTime.now();

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

    final bool isLocked = hasSecurityEnabled && !privacyState.isAuthenicated;

    final bool shouldBlur = _isBlurred;

    return Stack(
      children: [
        isLocked ? const LoginScreen() : widget.child,

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
