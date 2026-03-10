import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart'; // For Icons
import '../../../features/habit_tracker/domain/entities/habit_entity.dart';

class ImportService {
  static Future<List<HabitEntity>?> importHabitsFromCSV() async {
    try {
      // 1. Open Native File Browser (Only allow CSVs)
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      // User canceled the picker
      if (result == null || result.files.single.path == null) {
        return null; 
      }

      // 2. Read the file contents
      File file = File(result.files.single.path!);
      String csvString = await file.readAsString();

      // 3. Convert CSV string back to a 2D List
      List<List<dynamic>> csvTable = const CsvToListConverter().convert(csvString);

      if (csvTable.isEmpty || csvTable.length == 1) return []; // Empty file

      List<HabitEntity> importedHabits = [];

      // 4. Loop through rows (Skip row 0 because it's the Header row)
      for (int i = 1; i < csvTable.length; i++) {
        var row = csvTable[i];
        
        // Skip malformed rows that don't have our hidden system data
        if (row.length < 10) continue;

        // Parse Standard Data
        String title = row[0].toString();
        String freqString = row[1].toString();
        HabitFrequency frequency = HabitFrequency.values.firstWhere(
          (e) => e.name.toLowerCase() == freqString.toLowerCase(),
          orElse: () => HabitFrequency.daily,
        );
        DateTime createdAt = DateFormat('yyyy-MM-dd').parse(row[4].toString());
        
        // Parse Completed Dates History
        String datesString = row[5].toString();
        List<DateTime> completedDates = [];
        if (datesString.isNotEmpty) {
          var dateParts = datesString.split('|');
          for (var dp in dateParts) {
            String cleanDate = dp.replaceAll(RegExp(r'\s+'), '');
            if (cleanDate.isNotEmpty) {
              completedDates.add(DateFormat('yyyy-MM-dd').parse(cleanDate));
            }
          }
        }

        // Parse Hidden System Data (IDs, Colors, Icons)
        String id = row[6].toString();
        int iconCode = int.tryParse(row[7].toString()) ?? Icons.star.codePoint;
        int colorValue = int.tryParse(row[8].toString()) ?? 0xFF00B894; // Default Teal
        
        // Parse Target Days (e.g., specific days of the week)
        String targetDaysStr = row[9].toString();
        List<int> targetDays = [];
        if (targetDaysStr.isNotEmpty) {
          targetDays = targetDaysStr.split('|').map((e) => int.tryParse(e) ?? 1).toList();
        }

        // 5. Rebuild the Habit Object
        importedHabits.add(HabitEntity(
          id: id,
          title: title,
          iconCode: iconCode,
          colorValue: colorValue,
          frequency: frequency,
          targetDays: targetDays,
          completedDates: completedDates,
          createdAt: createdAt,
        ));
      }

      return importedHabits;
      
    } catch (e) {
      throw Exception("Failed to parse CSV file. Ensure it is a valid Growbit backup.");
    }
  }
}