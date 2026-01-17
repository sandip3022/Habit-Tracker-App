import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker_app_2026/main.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/habit_entity.dart';
import '../../../../core/theme/app_colors.dart'; 

class AddHabitPage extends ConsumerStatefulWidget {
  final HabitEntity? habitToEdit;

  const AddHabitPage({super.key, this.habitToEdit});

  @override
  ConsumerState<AddHabitPage> createState() => _AddHabitPageState();
}

class _AddHabitPageState extends ConsumerState<AddHabitPage> {
  final _titleController = TextEditingController();
  
  // Default State
  late Color _selectedColor;
  late int _selectedIconCode;
  HabitFrequency _frequency = HabitFrequency.daily;
  List<int> _selectedDays = [];

  // Curated "Modern Journal" Palette
  final List<Color> _colorOptions = [
    const Color(0xFF2C3E50), // Midnight (Primary)
    const Color(0xFFFF6B6B), // Coral (Secondary)
    const Color(0xFF6C5CE7), // Soft Purple
    const Color(0xFF00B894), // Teal
    const Color(0xFF0984E3), // Bright Blue
    const Color(0xFFE17055), // Burnt Orange
    const Color(0xFFFD79A8), // Pink
  ];

  // Common Habit Icons
 final List<IconData> _iconOptions = [
    Icons.auto_stories,      // Reading
    Icons.fitness_center,    // Gym
    Icons.water_drop,        // Water
    Icons.code,              // Coding
    Icons.self_improvement,  // Meditation
    Icons.directions_run,    // Running
    Icons.restaurant,        // Diet
    Icons.bed,               // Sleep
    Icons.savings,           // Finance
    Icons.palette,           // Art
    Icons.music_note,        // Music
    Icons.check_circle,      // General Task
  ];

  @override
  void initState() {
    super.initState();
    if (widget.habitToEdit != null) {
      // EDIT MODE: Pre-fill
      _titleController.text = widget.habitToEdit!.title;
      _selectedColor = Color(widget.habitToEdit!.colorValue);
      _selectedIconCode = widget.habitToEdit!.iconCode;
      _frequency = widget.habitToEdit!.frequency;
      _selectedDays = List.from(widget.habitToEdit!.targetDays);
    } else {
      // CREATE MODE: Defaults
      _selectedColor = _colorOptions[0];
      _selectedIconCode = _iconOptions[0].codePoint;
    }
  }

  void _saveHabit() {
    if (_titleController.text.trim().isEmpty) return;

    // Safety: If Specific Days selected but list is empty, force Daily
    if (_frequency == HabitFrequency.specificDays && _selectedDays.isEmpty) {
      _frequency = HabitFrequency.daily;
    }

    if (widget.habitToEdit != null) {
      // UPDATE
      final updatedHabit = HabitEntity(
        id: widget.habitToEdit!.id,
        title: _titleController.text.trim(),
        iconCode: _selectedIconCode,
        colorValue: _selectedColor.value,
        completedDates: widget.habitToEdit!.completedDates,
        frequency: _frequency,
        targetDays: _selectedDays,
        createdAt: widget.habitToEdit!.createdAt,
      );
      ref.read(habitNotifierProvider.notifier).updateHabit(updatedHabit, DateTime.now());
    } else {
      // CREATE
      final newHabit = HabitEntity(
        id: const Uuid().v4(),
        title: _titleController.text.trim(),
        iconCode: _selectedIconCode,
        colorValue: _selectedColor.value,
        completedDates: [],
        frequency: _frequency,
        targetDays: _selectedDays,
        createdAt: DateTime.now(),
      );
      ref.read(habitNotifierProvider.notifier).addHabit(newHabit, DateTime.now());
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isEditing = widget.habitToEdit != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isEditing ? "Edit Habit" : "New Habit"),
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Save Text Button
          TextButton(
            onPressed: _saveHabit,
            child: Text(
              "SAVE",
              style: textTheme.labelLarge?.copyWith(
                color: AppColors.primary,
                letterSpacing: 1.0,
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. TITLE INPUT (Minimalist) ---
            Text("WHAT DO YOU WANT TO DO?", 
              style: textTheme.labelSmall?.copyWith(color: AppColors.textSecondary, letterSpacing: 1.2)
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                controller: _titleController,
                style: textTheme.bodyLarge?.copyWith(fontSize: 18),
                decoration: InputDecoration(
                  hintText: "e.g. Read 10 pages",
                  hintStyle: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.5)),
                  border: InputBorder.none,
                  icon: Icon(Icons.edit_outlined, color: AppColors.primaryTint20),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // --- 2. FREQUENCY ---
            Text("FREQUENCY", 
               style: textTheme.labelSmall?.copyWith(color: AppColors.textSecondary, letterSpacing: 1.2)
            ),
            const SizedBox(height: 12),
            _buildFrequencyToggle(),
            
            // Show Day Selector only if "Specific Days" is active
            if (_frequency == HabitFrequency.specificDays) ...[
              const SizedBox(height: 16),
              _buildDaySelector(),
            ],

            const SizedBox(height: 32),

            // --- 3. APPEARANCE (Color & Icon) ---
            Text("APPEARANCE", 
               style: textTheme.labelSmall?.copyWith(color: AppColors.textSecondary, letterSpacing: 1.2)
            ),
            const SizedBox(height: 12),
            
            // Color Circles
            SizedBox(
              height: 50,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _colorOptions.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final color = _colorOptions[index];
                  final isSelected = _selectedColor == color;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = color),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: isSelected ? 48 : 40,
                      height: isSelected ? 48 : 40,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: isSelected 
                            ? Border.all(color: AppColors.textPrimary, width: 2.5) 
                            : null,
                        boxShadow: [
                          if (isSelected)
                            BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 8, offset: const Offset(0, 4))
                        ]
                      ),
                      child: isSelected 
                          ? const Icon(Icons.check, color: Colors.white, size: 20) 
                          : null,
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 24),

            // Icon Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _iconOptions.length,
              itemBuilder: (context, index) {
                final iconCode = _iconOptions[index];
                final isSelected = _selectedIconCode == iconCode.codePoint;
                
                return GestureDetector(
                  onTap: () => setState(() => _selectedIconCode = iconCode.codePoint),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? _selectedColor.withValues(alpha: 0.15) // Tinted background
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected 
                          ? Border.all(color: _selectedColor, width: 2) 
                          : Border.all(color: Colors.transparent),
                    ),
                    child: Icon(
                      IconData(iconCode.codePoint, fontFamily: 'MaterialIcons'),
                      color: isSelected ? _selectedColor : AppColors.textSecondary,
                      size: 26,
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 50), // Bottom spacing
          ],
        ),
      ),
    );
  }

  // --- WIDGET: Frequency Switcher ---
  Widget _buildFrequencyToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildToggleOption("Every Day", HabitFrequency.daily),
          _buildToggleOption("Specific Days", HabitFrequency.specificDays),
        ],
      ),
    );
  }

  Widget _buildToggleOption(String label, HabitFrequency val) {
    final isSelected = _frequency == val;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _frequency = val),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  // --- WIDGET: Day Selector Chips ---
  Widget _buildDaySelector() {
    final days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(7, (index) {
        // Mon = 1 ... Sun = 7
        final dayIndex = index + 1;
        final isSelected = _selectedDays.contains(dayIndex);
        
        return ChoiceChip(
          label: Text(days[index]),
          selected: isSelected,
          selectedColor: AppColors.secondary, // Uses the "Action" color
          backgroundColor: AppColors.surface,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedDays.add(dayIndex);
              } else {
                _selectedDays.remove(dayIndex);
              }
            });
          },
        );
      }),
    );
  }
}