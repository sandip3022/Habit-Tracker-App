
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:habit_tracker_app_2026/core/constants/app_assets.dart';
import 'package:habit_tracker_app_2026/features/habit_tracker/presentation/pages/home_page.dart';
import 'package:habit_tracker_app_2026/features/onboarding/presentation/pages/login_screen.dart';
import 'package:habit_tracker_app_2026/features/onboarding/presentation/pages/onboarding_screen.dart';
import 'package:hive/hive.dart';

class SplashScreen  extends ConsumerStatefulWidget{
const SplashScreen({super.key});

@override
ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with SingleTickerProviderStateMixin{
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState(){
    super.initState();
    // 1. Setup Animation (2 Seconds)
    _controller = AnimationController(vsync: this,
    duration: Duration(seconds: 2));

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutBack),
    );
    // 2. Start Animation & Logic
    _controller.forward();
    _getNextScreen();
  }

  Future<void> _getNextScreen() async {
    // Wait for animation + a little buffer
    await Future.delayed(const Duration(seconds: 2, milliseconds: 500));
  
  if (!mounted) return;

  // logic check
  final settingsBox = Hive.box('settings');
  const secureStorage = FlutterSecureStorage();
  final String? storedPin = await secureStorage.read(key: 'user_pin');
  final bool isOnboardingCompleted = settingsBox.get('onboardingCompleted', defaultValue: false);
  
  if (!isOnboardingCompleted){
    // CASE A: First Time -> Go to Onboarding
      _navigate(const OnboardingScreen());
  } else {
      final bool hasPin = storedPin != null && storedPin.isNotEmpty;
      final bool hasBiometrics = settingsBox.get('biometric_enabled', defaultValue: false);
    if (hasPin || hasBiometrics){
      _navigate(const LoginScreen());
    } else {
      _navigate(const HomePage());
    }
  }
  }

  void _navigate(Widget page){
    Navigator.of(context).pushReplacement(
    PageRouteBuilder(pageBuilder: (_,__,___)=>page,
    transitionsBuilder: (_,a,__,c) => FadeTransition(opacity: a,child: c,),
    transitionDuration: const Duration(microseconds: 800),
    )
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: colorScheme.surface, // Adapts to theme
      body: Semantics(
        label: 'app_is_loading'.tr(), 
        child: MergeSemantics(
          child: Center(
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Your Logo Icon
                  ExcludeSemantics(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          
                         if (!isDark) 
                            BoxShadow(
                              color: colorScheme.primary.withValues(alpha: 0.4), 
                              blurRadius: 20, 
                              offset: const Offset(0, 10),
                            )
                        ]
                      ),
                      child:  SizedBox(
                        width: 64,
                        height: 64,
                        child: Image.asset(AppAssets.appLogoPng )),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // App Name
                  Text(
                    "growbit".tr(),
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontSize: 24,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }















}


