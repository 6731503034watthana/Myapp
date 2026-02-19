import 'package:flutter/material.dart';
import 'package:smart_pantry/models/user.dart';
import 'package:smart_pantry/services/mock_data_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoggedIn = false;

  User? get user => _user;
  bool get isLoggedIn => _isLoggedIn;

  // Mock Login
  void login() {
    _user = MockDataService.getMockUser();
    _isLoggedIn = true;
    notifyListeners();
  }

  // Logout
  void logout() {
    _user = null;
    _isLoggedIn = false;
    notifyListeners();
  }

  // อัปเดต preferences
  void toggleNotifications(bool value) {
    _user?.preferences.notificationsEnabled = value;
    notifyListeners();
  }

  void toggleWeeklyReport(bool value) {
    _user?.preferences.weeklyReportEnabled = value;
    notifyListeners();
  }
}
