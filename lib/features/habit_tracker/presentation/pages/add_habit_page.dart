import 'package:easy_localization/easy_localization.dart';
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
  
  late Color _selectedColor;
  late IconData _selectedIcon; 
  
  HabitFrequency _frequency = HabitFrequency.daily;
  List<int> _selectedDays = [];

  final List<Color> _colorOptions = [
    const Color(0xFF2C3E50), // Midnight
    const Color(0xFFFF6B6B), // Coral
    const Color(0xFF6C5CE7), // Purple
    const Color(0xFF00B894), // Teal
    const Color(0xFF0984E3), // Blue
    const Color(0xFFE17055), // Orange
    const Color(0xFFFD79A8), // Pink
  ];

  final List<IconData> _iconOptions = [
    Icons.auto_stories,      
    Icons.fitness_center,    
    Icons.water_drop,        
    Icons.code,              
    Icons.self_improvement,  
    Icons.directions_run,    
    Icons.restaurant,        
    Icons.bed,               
    Icons.savings,           
    Icons.palette,           
    Icons.music_note,        
    Icons.check_circle,      
  ];

  @override
  void initState() {
    super.initState();
    if (widget.habitToEdit != null) {
      _titleController.text = widget.habitToEdit!.title;
      _selectedColor = Color(widget.habitToEdit!.colorValue);
      _selectedIcon = IconData(
         widget.habitToEdit!.iconCode, 
         fontFamily: 'MaterialIcons'
      );
      _frequency = widget.habitToEdit!.frequency;
      _selectedDays = List.from(widget.habitToEdit!.targetDays);
    } else {
      _selectedColor = _colorOptions[0];
      _selectedIcon = _iconOptions[0];
    }
  }

  void _saveHabit() {
    if (_titleController.text.trim().isEmpty) return;

    if (_frequency == HabitFrequency.specificDays && _selectedDays.isEmpty) {
      _frequency = HabitFrequency.daily;
    }

    if (widget.habitToEdit != null) {
      final updatedHabit = HabitEntity(
        id: widget.habitToEdit!.id,
        title: _titleController.text.trim(),
        iconCode: _selectedIcon.codePoint, 
        colorValue: _selectedColor.value,
        completedDates: widget.habitToEdit!.completedDates,
        frequency: _frequency,
        targetDays: _selectedDays,
        createdAt: widget.habitToEdit!.createdAt,
      );
      ref.read(habitNotifierProvider.notifier).updateHabit(updatedHabit, DateTime.now());
    } else {
      final newHabit = HabitEntity(
        id: const Uuid().v4(),
        title: _titleController.text.trim(),
        iconCode: _selectedIcon.codePoint,
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
    // 1. Get Theme Colors
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Helper text color (Grey in Light, Lighter Grey in Dark)
    final labelColor = isDark ? Colors.grey[400] : AppColors.textSecondary;

    return Scaffold(
      // No fixed background color
      appBar: AppBar(
        title: Text(widget.habitToEdit != null ? "edit_habit".tr() : "new_habit".tr()),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: colorScheme.onSurface), // Dynamic X icon
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _saveHabit,
            child: Text(
              "save_all_cap".tr(),
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
            // TITLE INPUT
            Text("what_do_you_want_to_do".tr(), 
              style: textTheme.labelSmall?.copyWith(color: labelColor, letterSpacing: 1.2)
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: colorScheme.surface, // <--- Dynamic Surface
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                controller: _titleController,
                style: textTheme.bodyLarge?.copyWith(fontSize: 18, color: colorScheme.onSurface),
                decoration: InputDecoration(
                  hintText: "example_habit".tr(),
                  hintStyle: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5)),
                  border: InputBorder.none,
                  icon: Icon(Icons.edit_outlined, color: AppColors.primary.withValues(alpha: 0.7)),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // FREQUENCY
            Text("frequency_all_cap", 
               style: textTheme.labelSmall?.copyWith(color: labelColor, letterSpacing: 1.2)
            ),
            const SizedBox(height: 12),
            _buildFrequencyToggle(colorScheme),
            
            if (_frequency == HabitFrequency.specificDays) ...[
              const SizedBox(height: 16),
              _buildDaySelector(colorScheme),
            ],

            const SizedBox(height: 32),

            // APPEARANCE
            Text("appearance_all_cap".tr(), 
               style: textTheme.labelSmall?.copyWith(color: labelColor, letterSpacing: 1.2)
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
                            // The border needs to contrast with the background (White on Dark, Black on Light)
                            ? Border.all(color: colorScheme.onSurface, width: 2.5) 
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
                final iconData = _iconOptions[index];
                final isSelected = _selectedIcon.codePoint == iconData.codePoint;
                
                return GestureDetector(
                  onTap: () => setState(() => _selectedIcon = iconData),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? _selectedColor.withValues(alpha: 0.15) 
                          : colorScheme.surface, // <--- Dynamic Surface
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected 
                          ? Border.all(color: _selectedColor, width: 2) 
                          : Border.all(color: Colors.transparent),
                    ),
                    child: Icon(
                      iconData,
                      // Unselected icons adapt to theme (Black vs White)
                      color: isSelected ? _selectedColor : colorScheme.onSurface.withValues(alpha: 0.5),
                      size: 26,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS ---
  Widget _buildFrequencyToggle(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colorScheme.surface, // <--- Dynamic
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildToggleOption("every_day".tr(), HabitFrequency.daily, colorScheme),
          _buildToggleOption("specific_days".tr(), HabitFrequency.specificDays, colorScheme),
        ],
      ),
    );
  }

  Widget _buildToggleOption(String label, HabitFrequency val, ColorScheme colorScheme) {
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
              // Selected: White | Unselected: Theme Text Color
              color: isSelected ? Colors.white : colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDaySelector(ColorScheme colorScheme) {
    final days = ["Mon".tr(), "Tue".tr(), "Wed".tr(), "Thu".tr(), "Fri".tr(), "Sat".tr(), "Sun".tr()];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(7, (index) {
        final dayIndex = index + 1;
        final isSelected = _selectedDays.contains(dayIndex);
        return ChoiceChip(
          label: Text(days[index]),
          selected: isSelected,
          selectedColor: AppColors.secondary,
          backgroundColor: colorScheme.surface, // <--- Dynamic
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          // Removing default border if you want a cleaner look, or keeping it
          side: isSelected ? BorderSide.none : BorderSide(color: colorScheme.onSurface.withValues(alpha: 0.1)),
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