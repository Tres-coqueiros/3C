import 'package:flutter/material.dart';

class AppProviderDepartament with ChangeNotifier {
  String _selectedDepartament = "";

  String get selectedDepartament => _selectedDepartament;

  void setSelectedDepartament(String department) {
    _selectedDepartament = department;
    notifyListeners();
  }
}
