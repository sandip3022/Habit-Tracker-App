import 'package:flutter/services.dart';

class Validators {
  static final RegExp _nameRegExp = RegExp(r"[a-zA-Z0-9\' ]");

  static List<TextInputFormatter> get nameInputFormatters {
    return [
      FilteringTextInputFormatter.allow(_nameRegExp),
    ];
  }

  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name cannot be empty';
    }
    
    // ^ means start, $ means end, + means one or more characters
    final fullMatchRegExp = RegExp(r"^[a-zA-Z0-9\' ]+$");
    if (!fullMatchRegExp.hasMatch(value)) {
      return 'Only letters, numbers, and apostrophes are allowed';
    }
    
    return null;
  }
}