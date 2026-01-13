import 'dart:async';
import 'package:flutter/material.dart';

class CountDownCircleWidget extends StatefulWidget {
  final int timeInSeconds;

  const CountDownCircleWidget({
    super.key,
    required this.timeInSeconds,
  });

  @override
  State<CountDownCircleWidget> createState() => _CountDownCircleWidgetState();
}

class _CountDownCircleWidgetState extends State<CountDownCircleWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late int remainingTime;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    remainingTime = widget.timeInSeconds;

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.timeInSeconds),
    )..forward();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingTime > 0) {
        setState(() {
          remainingTime--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      height: 250,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: 1 - _controller.value,
            strokeWidth: 2,
          ),
          Text(
            "$remainingTime s",
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
