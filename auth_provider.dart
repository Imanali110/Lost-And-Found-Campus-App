// lib/providers/auth_provider.dart
// Holds the currently logged-in user — accessible anywhere in the app

import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final _svc = AuthService();

  UserModel? _user;
  bool _loading = false;

  UserModel? get user    => _user;
  bool get isLoggedIn    => _user != null;
  bool get isLoading     => _loading;

  // Called on app start to restore session
  Future<void> init() async {
    _user = await _svc.getCurrentUser();
    notifyListeners();
  }

  Future<void> register({
    required String name,
    required String rollNumber,
    required String email,
    required String password,
  }) async {
    _loading = true; notifyListeners();
    try {
      _user = await _svc.register(
          name: name, rollNumber: rollNumber, email: email, password: password);
    } finally {
      _loading = false; notifyListeners();
    }
  }

  Future<void> login({required String email, required String password}) async {
    _loading = true; notifyListeners();
    try {
      _user = await _svc.login(email: email, password: password);
    } finally {
      _loading = false; notifyListeners();
    }
  }

  Future<void> logout() async {
    await _svc.logout();
    _user = null;
    notifyListeners();
  }
}
