import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateSelector extends StatelessWidget {
  final DateTime selectedDate;
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  const DateSelector({
    super.key,
    required this.selectedDate,
    required this.onNext,
    required this.onPrevious,
  });

  @override
  Widget build(BuildContext context) {
    final isToday = CalendarUtils.isSameDay(selectedDate, DateTime.now());

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      color: Colors.white, // Clean background
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // PREVIOUS BUTTON
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.grey),
            onPressed: onPrevious,
          ),

          // DATE DISPLAY
          Column(
            children: [
              Text(
                isToday ? "Today" : DateFormat('EEEE').format(selectedDate), // "Monday" or "Today"
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('MMM d, yyyy').format(selectedDate), // "Oct 24, 2025"
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600, // Matches your app style
                  fontFamily: 'Serif', // Matching your headers
                  color: Colors.black,
                ),
              ),
            ],
          ),

          // NEXT BUTTON
          IconButton(
            icon: Icon(
              Icons.arrow_forward_ios, 
              size: 20, 
              // Disable "Next" button if date is in future (Optional, remove logic if you want future planning)
              color: Colors.grey
            ),
            onPressed: onNext,
          ),
        ],
      ),
    );
  }
}

// Simple Utility to check dates
class CalendarUtils {
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}