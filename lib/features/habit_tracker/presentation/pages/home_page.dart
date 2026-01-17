import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker_app_2026/features/habit_tracker/presentation/pages/Journal_page.dart';
import 'package:habit_tracker_app_2026/features/habit_tracker/presentation/pages/account_page.dart';
import 'package:habit_tracker_app_2026/features/habit_tracker/presentation/pages/progress_page.dart';
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
      appBar: AppBar(
        actions: [
          InkWell(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (_) => const TimerHome()));
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Icon(Icons.punch_clock_outlined),
            ),
          ),
        ],
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

             Text("Hello $username, Welcome to....",
             style: TextStyle(fontSize: 16),),
            const Text("Habit Tracker"),
          ],
        ),
        backgroundColor: Colors.black,
      ),
     
      body: pagelist[_selectedIndex],
      
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Journal',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Progress',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Account',
          ),
        ],
      ),
    );
  }


}