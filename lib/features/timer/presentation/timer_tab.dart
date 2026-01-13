
import 'package:flutter/material.dart';
import 'package:habit_tracker_app_2026/features/timer/presentation/count_down_circle_widget.dart';

class  TimerTab extends StatefulWidget {
  const TimerTab({Key? key}) : super(key: key);

  @override
  State<TimerTab> createState() => _TimerTabState();
}

class _TimerTabState extends State<TimerTab> {

 

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric( vertical: 20, horizontal: 30),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: const Color.fromARGB(255, 34, 27, 27),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha( 1),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: 
          Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Timer Tab',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Icon(
                  Icons.timer,
                  size: 30,
                ),
              ],
            ),
            SizedBox(height: 20),
            CountDownCircleWidget(timeInSeconds: 60)
          ],
        ),));
  }
}
