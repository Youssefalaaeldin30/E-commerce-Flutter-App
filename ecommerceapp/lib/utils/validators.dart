import 'package:flutter/material.dart';

bool isValidEmail(String email) {
  final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  return regex.hasMatch(email);
}

String getPasswordStrength(String password) {
  if (password.length < 6) return "Weak";
  if (password.length < 10) return "Medium";
  return "Strong";
}

Color getStrengthColor(String strength) {
  switch (strength) {
    case "Weak":
      return Colors.red;
    case "Medium":
      return Colors.orange;
    case "Strong":
      return Colors.green;
    default:
      return Colors.grey;
  }
}
