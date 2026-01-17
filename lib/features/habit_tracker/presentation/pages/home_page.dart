import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker_app_2026/features/habit_tracker/presentation/pages/Journal_page.dart';
import 'package:habit_tracker_app_2026/features/habit_tracker/presentation/pages/account_page.dart';
import 'package:habit_tracker_app_2026/features/habit_tracker/presentation/pages/progress_page.dart';
import 'package:habit_tracker_app_2026/features/habit_tracker/presentation/widgets/app_bar.dart';
import 'package:habit_tracker_app_2026/features/timer/presentation/timer_home.dart';
import 'package:habit_tracker_app_2026/main.dart';
import '../state_management/habit_provider.dart';


class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

final pagelist = [
  JournalPage(),
  const ProgressPage(),
  const AccountPage()
];

class _HomePageState extends ConsumerState<HomePage> {
  var _selectedIndex = 0;
  @override
  void initState() {
    super.initState();
    // Load habits for the INITIAL date (Today)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final date = ref.read(selectedDateProvider);
      ref.read(habitNotifierProvider.notifier).loadHabits(date);
    });
  }

  @override
  Widget build(BuildContext context) {
    var username = 'Sandip';

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: HomeAppBar(
        userName: username,
        onTimerTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const TimerHome()));
        },
      ),
     
      body: pagelist[_selectedIndex],
      
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items:  [
          BottomNavigationBarItem(
            icon: _selectedIndex == 0 ? Icon(Icons.book) : Icon(Icons.book_outlined),
            label: 'Journal',
          ),
          BottomNavigationBarItem(
            icon:_selectedIndex == 1 ? Icon(Icons.bar_chart) :  Icon(Icons.bar_chart_outlined),
            label: 'Progress',
          ),
          BottomNavigationBarItem(
            icon: _selectedIndex == 2 ? Icon(Icons.account_circle) : Icon(Icons.account_circle_outlined),
            label: 'Account',
          ),
        ],
      ),
    );
  }


}