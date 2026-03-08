import 'package:flutter/material.dart';
import 'package:habit_tracker_app_2026/features/timer/presentation/clock_tab.dart';
import 'package:habit_tracker_app_2026/features/timer/presentation/focus_timer_page.dart';

class TimerHome extends StatefulWidget {
  const TimerHome({super.key});

  @override
  State<TimerHome> createState() => _TimerHomeState();
}

class _TimerHomeState extends State<TimerHome> {
  int _selectedIndex = 0;

  static  final List<Widget> _pages = <Widget>[
    ClockTab(),
    // TimerTab(),
    FocusTimerPage(),
    Center(child: Text('Stopwatch', style: TextStyle(fontSize: 32))),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timer Home'),
        centerTitle: true,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time),
            label: 'Clock',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timer),
            label: 'Timer',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.av_timer),
            label: 'Stopwatch',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}