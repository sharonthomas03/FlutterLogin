import 'package:flutter/material.dart';
import '../model/user_model.dart';
import '../model/login_request_model.dart';
import '../model/register_request_model.dart';
import '../service/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService authService;

  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  AuthViewModel({required this.authService});

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool value) {
    _isLoading = value;
    Future.microtask(() {
      if (hasListeners) notifyListeners();
    });
  }

  void _setError(String? message) {
    _errorMessage = message;
    Future.microtask(() {
      if (hasListeners) notifyListeners();
    });
  }

  Future<User?> checkSavedUser() async {
    _setLoading(true);
    try {
      _currentUser = await authService.getSavedUser();
      _setError(null);
      return _currentUser;
    } catch (e) {
      _setError(e.toString());
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<User?> login({required String email, required String password}) async {
    _setLoading(true);
    _setError(null);
    try {
      final request = LoginRequestModel(email: email, password: password);
      _currentUser = await authService.login(request);
      return _currentUser;
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<User?> register({
    required String username,
    required String email,
    required String password,
    String bio = '',
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      final request = RegisterRequestModel(
        username: username,
        email: email,
        password: password,
        bio: bio,
      );
      _currentUser = await authService.register(request);
      return _currentUser;
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    try {
      await authService.logout();
      _currentUser = null;
      _setError(null);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  void updateCurrentUser(User user) {
    _currentUser = user;
    notifyListeners();
  }
}
