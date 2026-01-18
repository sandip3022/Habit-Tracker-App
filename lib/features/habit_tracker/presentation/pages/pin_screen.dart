import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../state_management/privacy_provider.dart';

enum PinMode { create, verify }

class PinScreen extends ConsumerStatefulWidget {
  final PinMode mode;
  final Function(String)? onSuccess; 
  final String? title; 

  const PinScreen({super.key, required this.mode, this.onSuccess, this.title});

  @override
  ConsumerState<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends ConsumerState<PinScreen> {
  String _enteredPin = "";
  String _firstPinAttempt = ""; 
  bool _isConfirming = false; 
  
  String get _displayTitle {
    if (widget.title != null) return widget.title!;
    if (widget.mode == PinMode.verify) return "Enter your PIN";
    if (_isConfirming) return "Confirm your PIN";
    return "Create a PIN";
  }

  void _onNumberTap(String number) {
    if (_enteredPin.length < 4) {
      setState(() => _enteredPin += number);
      if (_enteredPin.length == 4) _handlePinComplete();
    }
  }

  void _onDeleteTap() {
    if (_enteredPin.isNotEmpty) {
      setState(() => _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1));
    }
  }

  void _handlePinComplete() async {
    if (widget.mode == PinMode.create) {
      if (!_isConfirming) {
        setState(() {
          _firstPinAttempt = _enteredPin;
          _enteredPin = "";
          _isConfirming = true;
        });
      } else {
        if (_enteredPin == _firstPinAttempt) {
           widget.onSuccess?.call(_enteredPin);
        } else {
          _showError("PINs do not match. Try again.");
          setState(() {
            _enteredPin = "";
            _firstPinAttempt = "";
            _isConfirming = false;
          });
        }
      }
    } else {
      bool isValid = await ref.read(privacyProvider.notifier).verifyPin(_enteredPin);
      if (isValid) {
        widget.onSuccess?.call(_enteredPin);
      } else {
        _showError("Incorrect PIN");
        setState(() => _enteredPin = "");
      }
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 1. Get Theme Data
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // No fixed background color (Uses Theme Default)
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          // Dynamic Icon Color
          icon: Icon(Icons.close, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 1. Title
          Text(
            _displayTitle, 
            style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)
          ),
          const SizedBox(height: 30),

          // 2. Dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: index < _enteredPin.length 
                      ? AppColors.primary 
                      // Unfilled dots: Dynamic grey
                      : AppColors.primary.withValues(alpha: isDark ? 0.4 : 0.2),
                ),
              );
            }),
          ),
          
          const Spacer(),

          // 3. Numpad
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 12,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: 1.5,
              ),
              itemBuilder: (context, index) {
                if (index == 9) return const SizedBox(); // Empty bottom left
                if (index == 11) {
                  // Backspace
                  return IconButton(
                    onPressed: _onDeleteTap,
                    icon: const Icon(Icons.backspace_outlined, size: 28),
                    // Dynamic Icon Color
                    color: colorScheme.onSurface,
                  );
                }
                
                String val = (index == 10) ? "0" : "${index + 1}";
                
                return GestureDetector(
                  onTap: () => _onNumberTap(val),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      // Dynamic Key Background (White vs Slate)
                      color: colorScheme.surface,
                      border: Border.all(
                        // Dynamic Border (Grey vs Subtle White)
                        color: isDark ? Colors.white12 : Colors.grey.withValues(alpha: 0.2)
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      val,
                      style: TextStyle(
                        fontSize: 24, 
                        fontWeight: FontWeight.bold,
                        // Dynamic Number Color
                        color: colorScheme.onSurface
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}