import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:uuid/uuid.dart';

// Import Provider & Entity
import '../../../../main.dart';
import '../../domain/entities/habit_entity.dart';

class AddHabitPage extends ConsumerStatefulWidget {
  const AddHabitPage({super.key, this.habit});

  final HabitEntity? habit;

  @override
  ConsumerState<AddHabitPage> createState() => _AddHabitPageState();
}

class _AddHabitPageState extends ConsumerState<AddHabitPage> {
  final _titleController = TextEditingController();
  final isColorSelected = true;


  // Default values
  Color _selectedColor = Colors.blue;
  DateTime? _startDate = DateTime.now();
  DateTime? _endDate;
  int _selectedIconCode = 0xe198; 
  HabitFrequency _selectedFrequency = HabitFrequency.daily;
  // water_drop
  // You can extend Entity to include frequency, for now we stick to basic fields

  final List<Color> _colorOptions = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
  ];

  final List<int> _iconOptions = [
    0xe198,
    0xeb43,
    0xe0b0,
    0xe156,
    0xe318,
    0xe52f,
  ];

  @override
  void initState() {
    if(widget.habit != null) {
      _titleController.text = widget.habit!.title;
      _selectedColor = Color(widget.habit!.colorValue);
      _selectedIconCode = widget.habit!.iconCode;
      _startDate = widget.habit!.createdAt;
      _endDate = widget.habit!.validUntil;
    }
    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _saveHabit() {
    if (_titleController.text.isEmpty) return;

    // 1. Create the new Entity
    final newHabit = HabitEntity(
      id: const Uuid().v4(), // Generate ID
      title: _titleController.text,
      iconCode: _selectedIconCode,
      colorValue: _selectedColor.value,
      createdAt: _startDate,
      validUntil: _endDate,
      completedDates: [],
      frequency: _selectedFrequency, // Default frequency
      targetDays: [], // Start empty
      // Add other fields like frequency here if Entity supports it
    );

    // 2. Use Riverpod to save (calls UseCase -> Repository -> Hive)
    // Note: You need to add an 'addHabit' method to your HabitNotifier in habit_provider.dart
    ref.read(habitNotifierProvider.notifier).addHabit(newHabit);

    // 3. Close screen
    Navigator.pop(context);
  }

  void _updateHabit() {
    if (_titleController.text.isEmpty || widget.habit == null) return;

    // 1. Create the updated Entity
    final updatedHabit = HabitEntity(
      id: widget.habit!.id, // Keep same ID
      title: _titleController.text,
      iconCode: _selectedIconCode,
      colorValue: _selectedColor.value,
      createdAt: _startDate,
      validUntil: _endDate,
      frequency: widget.habit?.frequency ?? HabitFrequency.daily,
      targetDays: widget.habit?.targetDays ?? [],
      completedDates: widget.habit!.completedDates, // Preserve completed dates
      // Add other fields like frequency here if Entity supports it
    );

    // 2. Use Riverpod to update (calls UseCase -> Repository -> Hive)
    ref.read(habitNotifierProvider.notifier).updateHabit(updatedHabit);

    // 3. Close screen
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "Create HabitModel",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Input
            const Text(
              "NAME",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: "e.g. Read 10 pages",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Icon Selector
            const Text(
              "ICON",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            _buildIconSelector(),
            const SizedBox(height: 24),

            // Color Selector
            const Text(
              "COLOR",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            _buildColorSelector(),
            const SizedBox(height: 8),
            _dateRangePicker(),
            const SizedBox(height: 8), 
            _frequencyDropdown(),
            const SizedBox(height: 8),
            _dayChipSelector(widget.habit),
            const SizedBox(height: 80), // Extra space for FAB
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: widget.habit == null ? _saveHabit : _updateHabit,
            child: Text(
              widget.habit == null ? "Save HabitModel" : "Update HabitModel",
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconSelector() {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: _iconOptions.map((iconCode) {
        final isSelected = _selectedIconCode == iconCode;
        return GestureDetector(
          onTap: () => setState(() => _selectedIconCode = iconCode),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected
                  ? _selectedColor.withValues(alpha: 0.2)
                  : Colors.white,
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(color: _selectedColor, width: 2)
                  : null,
            ),
            child: Icon(
              IconData(iconCode, fontFamily: 'MaterialIcons'),
              color: isSelected ? _selectedColor : Colors.grey,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildColorSelector() {
    return Wrap(
      spacing: 12,
      children: _colorOptions.map((color) {
        return GestureDetector(
          onTap: () => setState(() => _selectedColor = color),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: _selectedColor.toARGB32() == color.toARGB32()
                  ? Border.all(color: Colors.black, width: 3)
                  : null,
            ),
            child: _selectedColor.toARGB32() == color.toARGB32()
                ? const Icon(Icons.check, color: Colors.white)
                : null,
          ),
        );
      }).toList(),
    );
  }

  Widget _dateRangePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "DURATION",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),

        InkWell(
          onTap: () async {
            // 1. Open the Flutter Date Range Picker
            final DateTimeRange? picked = await showDateRangePicker(
              context: context,
              firstDate: DateTime.now(), // Habits usually start today or later
              lastDate: DateTime.now().add(
                const Duration(days: 365 * 2),
              ), // Limit to 2 years
              builder: (context, child) {
                return Theme(
                  data: ThemeData.light().copyWith(
                    primaryColor: Colors.black, // Header color
                    colorScheme: const ColorScheme.light(
                      primary: Colors.black, // Selection color
                      onPrimary: Colors.white,
                      surface: Colors.white,
                      onSurface: Colors.black,
                    ),
                  ),
                  child: child!,
                );
              },
            );

            // 2. Update State if user selected a range
            if (picked != null) {
              setState(() {
                _startDate = picked.start;
                _endDate = picked.end;
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.transparent,
              ), // Keeps layout stable
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.black, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _startDate == null
                        ? "Select Start & End Date"
                        : "${DateFormat('MMM d').format(_startDate ?? DateTime.now())} - ${DateFormat('MMM d').format(_endDate ?? DateTime.now())}",
                    style: TextStyle(
                      fontSize: 16,
                      color: _startDate == null
                          ? Colors.grey[400]
                          : Colors.black,
                      fontWeight: _startDate == null
                          ? FontWeight.normal
                          : FontWeight.w600,
                    ),
                  ),
                ),
                if (_startDate != null)
                  const Icon(Icons.edit, size: 16, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  
}


Widget _frequencyDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "FREQUENCY",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButton<HabitFrequency>(
          value: HabitFrequency.daily,
          isExpanded: true,
          items: HabitFrequency.values.map((frequency) {
            String text;
            switch (frequency) {
              case HabitFrequency.daily:
                text = "Daily";
                break;
              case HabitFrequency.weekly:
                text = "Weekly";
                break;
              case HabitFrequency.specificDays:
                text = "Specific Days";
                break;
            }
            return DropdownMenuItem<HabitFrequency>(
              value: frequency,
              child: Text(text),
            );
          }).toList(),
          onChanged: (value) {
            // Handle frequency change
            if (value != null) {
              setState(() {
                _selectedFrequency = value;
              });
            }
          },
        ),
      ],
    );

  }
  
  Widget _dayChipSelector(HabitEntity? habit) {
    final daysOfWeek = [
      'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "SELECT DAYS",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: List<Widget>.generate(7, (int index) {
            final day = index; // 0 = Mon, 6 = Sun
            final isSelected = habit?.targetDays.contains(day) ?? false;
            return ChoiceChip(
              label: Text(daysOfWeek[index]),
              selected: isSelected,
              selectedColor: Colors.black,
              onSelected: (bool selected) {
                setState(() {
                  if (selected) {
                    habit?.targetDays.add(day);
                  } else {
                    habit?.targetDays.remove(day);
                  }
                });
              },
            );
          }),
        ),
      ],
    );
  }
}