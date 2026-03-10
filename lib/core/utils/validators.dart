import 'package:flutter/services.dart';

class Validators {
  // 1. The Regex Pattern
  static final RegExp _nameRegExp = RegExp(r"[a-zA-Z0-9\' ]");

  // 2. The Input Formatter (Blocks typing bad characters instantly)
  static List<TextInputFormatter> get nameInputFormatters {
    return [
      FilteringTextInputFormatter.allow(_nameRegExp),
    ];
  }

  // 3. The Form Validator (Shows error text under the field)
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name cannot be empty';
    }
    
    // Check if the whole string matches our allowed characters
    // ^ means start, $ means end, + means one or more characters
    final fullMatchRegExp = RegExp(r"^[a-zA-Z0-9\' ]+$");
    if (!fullMatchRegExp.hasMatch(value)) {
      return 'Only letters, numbers, and apostrophes are allowed';
    }
    
    return null; // Null means the input is valid!
  }
}