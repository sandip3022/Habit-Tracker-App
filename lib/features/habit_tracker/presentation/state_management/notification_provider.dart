import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker_app_2026/core/services/notification_service.dart';
import 'package:hive/hive.dart';

class NotificationState {
  final bool isNotificationOn;
  final TimeOfDay selectedTime;

  NotificationState({
    required this.isNotificationOn,
    required this.selectedTime,
  });

  NotificationState copyWith({
    bool? isNotificationOn,
    TimeOfDay? selectedTime,
  }) {
    return NotificationState(
      isNotificationOn: isNotificationOn ?? this.isNotificationOn,
      selectedTime: selectedTime ?? this.selectedTime,
    );
  }
}

class NotificationProvider extends Notifier<NotificationState> {
  final _service = NotificationService();
  final _boxName = 'settings';

  @override
  NotificationState build() {
    _initAndLoad();
    return NotificationState(
      isNotificationOn: false,
      selectedTime: const TimeOfDay(hour: 9, minute: 0),
    );
  }

  Future<void> _initAndLoad() async {
    final settingsBox = await Hive.openBox(_boxName);

    final bool isEnabled = settingsBox.get(
      'isNotificationOn',
      defaultValue: false,
    );
    final String savedTime = settingsBox.get(
      'notificationTime',
      defaultValue: '09:00',
    );

    final parts = savedTime.split(':');
    final time = TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );

    state = NotificationState(isNotificationOn: isEnabled, selectedTime: time);

    if (isEnabled) {
      await _service.scheduleDailyNotification(time: time);
    }
  }

  Future<void> toggleNotification(bool value) async {
    state = state.copyWith(isNotificationOn: value);
    final box = Hive.box(_boxName);
    await box.put('isNotificationOn', value);

    if (value) {
      bool granted = await _service.requestPermissions();
      if (granted) {
        await _service.scheduleDailyNotification(time: state.selectedTime);
      } else {
        state = state.copyWith(isNotificationOn: false);
        await box.put('isNotificationOn', false);
      }
    } else {
      await _service.cancelNotifications();
    }
  }

  Future<void> updateTime(TimeOfDay newTime) async {
    state = state.copyWith(selectedTime: newTime);
    final box = Hive.box(_boxName);
    await box.put('notificationTime', '${newTime.hour}:${newTime.minute}');

    if (state.isNotificationOn) {
      await _service.scheduleDailyNotification(time: newTime);
    }
  }
}


final notificationProvider =
    NotifierProvider<NotificationProvider, NotificationState>(() {
      return NotificationProvider();
    });
