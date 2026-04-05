import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:habit_tracker_app_2026/features/timer/presentation/clock_tab.dart';
import 'package:habit_tracker_app_2026/features/timer/presentation/focus_timer_page.dart';
import 'package:habit_tracker_app_2026/features/timer/presentation/stopwatch_tab.dart';

class TimerHome extends StatefulWidget {
  const TimerHome({super.key});

  @override
  State<TimerHome> createState() => _TimerHomeState();
}

class _TimerHomeState extends State<TimerHome> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = <Widget>[
    ClockTab(),
    FocusTimerPage(),
    StopwatchTab(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('timer_home').tr(), centerTitle: true),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time),
            label: 'clock'.tr(),
          ),
          BottomNavigationBarItem(icon: Icon(Icons.timer_outlined), label: 'timer'.tr()),
          BottomNavigationBarItem(
            icon: Icon(Icons.av_timer),
            label: 'stopwatch'.tr(),
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Theme.of(context).colorScheme.secondary,
      ),
    );
  }
}
