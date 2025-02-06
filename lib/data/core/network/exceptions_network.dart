import 'package:flutter/material.dart';

class ErrorNotifier {
  static final ValueNotifier<String?> errorMessage = ValueNotifier(null);

  static void showError(String message) {
    errorMessage.value = message;
  }
}
