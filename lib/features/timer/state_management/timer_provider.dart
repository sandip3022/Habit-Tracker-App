import 'dart:async';
import 'package:flutter/services.dart'; // Required for HapticFeedback
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TimerState {
  final int totalSeconds;
  final int remainingSeconds;
  final bool isRunning;

  TimerState({
    required this.totalSeconds,
    required this.remainingSeconds,
    required this.isRunning,
  });

  double get progress => totalSeconds == 0 ? 0 : 1 - (remainingSeconds / totalSeconds);
  
  String get timeString {
    int minutes = remainingSeconds ~/ 60;
    int seconds = remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  TimerState copyWith({int? totalSeconds, int? remainingSeconds, bool? isRunning}) {
    return TimerState(
      totalSeconds: totalSeconds ?? this.totalSeconds,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isRunning: isRunning ?? this.isRunning,
    );
  }
}

class TimerNotifier extends StateNotifier<TimerState> {
  TimerNotifier() : super(TimerState(totalSeconds: 25 * 60, remainingSeconds: 25 * 60, isRunning: false));

  Timer? _timer;

  void setDuration(int minutes) {
    _timer?.cancel();
    state = TimerState(
      totalSeconds: minutes * 60,
      remainingSeconds: minutes * 60,
      isRunning: false,
    );
  }

  void start() {
    if (state.remainingSeconds > 0 && !state.isRunning) {
      state = state.copyWith(isRunning: true);
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (state.remainingSeconds > 0) {
          state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
        } else {
          stop(); // Timer finished
          _playAlarmVibration(); // Trigger the buzz!
        }
      });
    }
  }

  void pause() {
    _timer?.cancel();
    state = state.copyWith(isRunning: false);
  }

  void stop() {
    _timer?.cancel();
    state = state.copyWith(isRunning: false, remainingSeconds: state.totalSeconds);
  }

  void _playAlarmVibration() async {
    // Vibrate 4 times in quick succession
    for (int i = 0; i < 4; i++) {
      HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 400));
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final timerProvider = StateNotifierProvider<TimerNotifier, TimerState>((ref) {
  return TimerNotifier();
});