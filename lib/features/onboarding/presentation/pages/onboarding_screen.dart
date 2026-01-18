import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker_app_2026/features/habit_tracker/domain/entities/habit_entity.dart';
import 'package:habit_tracker_app_2026/features/habit_tracker/presentation/pages/home_page.dart';
import 'package:habit_tracker_app_2026/features/habit_tracker/presentation/pages/privacy_lock_page.dart';
import 'package:habit_tracker_app_2026/main.dart';
import '../../../../core/theme/app_colors.dart';
import '../state_management/user_provider.dart';
import 'package:uuid/uuid.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _nameController = TextEditingController();
  
  int _currentPage = 0;
  final Set<String> _selectedHabits = {}; // Store IDs of selected predefined habits

  // Pre-defined habits for Step 2
  final List<Map<String, dynamic>> _starterHabits = [
    {'title': 'Drink Water', 'icon': 0xe0b0, 'color': 0xFF0984E3}, // Blue
    {'title': 'Read Books', 'icon': 0xe198, 'color': 0xFF6C5CE7},  // Purple
    {'title': 'Exercise', 'icon': 0xeb43, 'color': 0xFFFF6B6B},    // Coral
    {'title': 'Meditation', 'icon': 0xe318, 'color': 0xFF00B894},  // Teal
    {'title': 'Journaling', 'icon': 0xe156, 'color': 0xFFE17055},  // Orange
    {'title': 'Early Sleep', 'icon': 0xf06b, 'color': 0xFF2C3E50}, // Midnight
  ];

  void _nextPage() {
    _pageController.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
  }

  Future<void> _finishOnboarding() async {
    // 1. Create selected habits
    for (var habitData in _starterHabits) {
      if (_selectedHabits.contains(habitData['title'])) {
        final habit = HabitEntity(
          id: const Uuid().v4(),
          title: habitData['title'],
          iconCode: habitData['icon'],
          colorValue: habitData['color'],
          completedDates: [],
          frequency: HabitFrequency.daily,
          targetDays: [],
          createdAt: DateTime.now(),
        );
        ref.read(habitNotifierProvider.notifier).addHabit(habit, DateTime.now());
      }
    }
    
    // 2. Save Name & Complete Flag
    await ref.read(userProvider.notifier).setName(_nameController.text.trim());
    await ref.read(userProvider.notifier).completeOnboarding();

    // 3. Go Home
    if (!mounted) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomePage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Progress Indicator (Optional)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: LinearProgressIndicator(
                value: (_currentPage + 1) / 3,
                backgroundColor: Colors.grey[200],
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(), // Disable swipe to force buttons
                onPageChanged: (idx) => setState(() => _currentPage = idx),
                children: [
                  _buildNameStep(),
                  _buildHabitStep(),
                  _buildSecurityStep(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- STEP 1: NAME ---
  Widget _buildNameStep() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Let's get started", style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Text("What should we\ncall you?", style: Theme.of(context).textTheme.displayMedium),
          const SizedBox(height: 32),
          TextField(
            controller: _nameController,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              hintText: "Your Name",
              hintStyle: TextStyle(color: Colors.grey[300]),
              border: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary, width: 2)),
            ),
            onChanged: (val) => setState(() {}), // Rebuild to enable button
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _nameController.text.isNotEmpty ? _nextPage : null,
              child: const Text("Next Step"),
            ),
          )
        ],
      ),
    );
  }

  // --- STEP 2: HABITS ---
  Widget _buildHabitStep() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Kickstart your journey", style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Text("Pick some habits", style: Theme.of(context).textTheme.displayMedium),
          const SizedBox(height: 8),
          Text("You can edit these later", style: TextStyle(color: Colors.grey[500], fontSize: 14)),
          const SizedBox(height: 32),
          
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.3,
              ),
              itemCount: _starterHabits.length,
              itemBuilder: (context, index) {
                final habit = _starterHabits[index];
                final isSelected = _selectedHabits.contains(habit['title']);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) _selectedHabits.remove(habit['title']);
                      else _selectedHabits.add(habit['title']);
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? Colors.transparent : Colors.grey[200]!,
                      ),
                      boxShadow: isSelected 
                          ? [BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4))] 
                          : [],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(IconData(habit['icon'], fontFamily: 'MaterialIcons'), 
                             size: 32, 
                             color: isSelected ? Colors.white : Color(habit['color'])),
                        const SizedBox(height: 12),
                        Text(habit['title'], 
                             style: TextStyle(
                               fontWeight: FontWeight.bold, 
                               color: isSelected ? Colors.white : AppColors.textPrimary
                             )),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          Row(
            children: [
              TextButton(onPressed: _nextPage, child: const Text("Skip")),
              const Spacer(),
              ElevatedButton(onPressed: _nextPage, child: const Text("Next Step")),
            ],
          )
        ],
      ),
    );
  }

  // --- STEP 3: SECURITY ---
  Widget _buildSecurityStep() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
           Icon(Icons.lock_outline_rounded, size: 80, color: AppColors.primary),
           const SizedBox(height: 24),
           Text("Protect your privacy", style: Theme.of(context).textTheme.displayMedium, textAlign: TextAlign.center),
           const SizedBox(height: 12),
           Text("Secure your journal with a PIN or Biometrics.", 
             textAlign: TextAlign.center, 
             style: TextStyle(color: AppColors.textSecondary)
           ),
           const SizedBox(height: 48),

           // Setup Button
           SizedBox(
             width: double.infinity,
             child: ElevatedButton(
               onPressed: () {
                 // Push Privacy Page, then finish on return
                 Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyLockPage()))
                     .then((_) => _finishOnboarding());
               },
               child: const Text("Set up Security"),
             ),
           ),
           const SizedBox(height: 16),
           
           // Skip Button
           TextButton(
             onPressed: _finishOnboarding, 
             child: Text("Skip for now", style: TextStyle(color: AppColors.textSecondary))
           ),
        ],
      ),
    );
  }
}