import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../state_management/privacy_provider.dart';

enum PinMode { create, verify }

class PinScreen extends ConsumerStatefulWidget {
  final PinMode mode;
  final Function(String)? onSuccess; // Callback when PIN is correct/created
  final String? title; // Override title

  const PinScreen({super.key, required this.mode, this.onSuccess, this.title});

  @override
  ConsumerState<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends ConsumerState<PinScreen> {
  String _enteredPin = "";
  String _firstPinAttempt = ""; // Used for "Confirm PIN" step in Create mode
  bool _isConfirming = false; // Are we on the second step of creation?
  
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
        // Step 1 done, move to Step 2 (Confirm)
        setState(() {
          _firstPinAttempt = _enteredPin;
          _enteredPin = "";
          _isConfirming = true;
        });
      } else {
        // Step 2 done, check match
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
      // Verify Mode
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 1. Title
          Text(_displayTitle, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
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
                      : AppColors.primary.withValues(alpha: 0.2),
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
                    color: AppColors.textPrimary,
                  );
                }
                
                String val = (index == 10) ? "0" : "${index + 1}";
                return GestureDetector(
                  onTap: () => _onNumberTap(val),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.surface,
                      border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      val,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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