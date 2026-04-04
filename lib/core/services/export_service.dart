import 'dart:typed_data';
import 'package:csv/csv.dart';
import 'package:file_saver/file_saver.dart';
import 'package:intl/intl.dart';
import '../../../features/habit_tracker/domain/entities/habit_entity.dart';

class ExportService {
  static Future<bool> exportHabitsToCSV(List<HabitEntity> habits) async {
    try {
      List<List<dynamic>> rows = [];
      rows.add([
        "Habit Title",
        "Frequency",
        "Current Streak",
        "Total Completions",
        "Created Date",
        "All Completed Dates",
        "sys_id", 
        "sys_icon", 
        "sys_color", 
        "sys_targetDays",
      ]);

      for (var habit in habits) {
        String completionHistory = habit.completedDates
            .map((date) => DateFormat('yyyy-MM-dd').format(date))
            .join(' | ');

        String targetDaysStr = habit.targetDays.join(' | ');

        rows.add([
          habit.title,
          habit.frequency.name.toUpperCase(),
          habit.currentStreak,
          habit.completedDates.length,
          DateFormat('yyyy-MM-dd').format(habit.createdAt ?? DateTime.now()),
          completionHistory, 
          habit.id,
          habit.iconCode,
          habit.colorValue,
          targetDaysStr
          
        ]);
      }

      String csvData = const ListToCsvConverter().convert(rows);
      Uint8List bytes = Uint8List.fromList(csvData.codeUnits);

      final String timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      
      final String? resultPath = await FileSaver.instance.saveAs(
        name: 'GroBit_Export_$timestamp',
        bytes: bytes,
        ext: 'csv',
        mimeType: MimeType.csv,
      );
      
      return resultPath != null;
      
    } catch (e) {
      throw Exception("Failed to export data");
    }
  }
}