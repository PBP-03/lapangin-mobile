import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class UserProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  bool get isLoggedIn => _user != null; // Alias for isAuthenticated
  bool get isUser => _user?.isUser ?? false;
  bool get isMitra => _user?.isMitra ?? false;
  bool get isAdmin => _user?.isAdmin ?? false;

  final AuthService _authService = AuthService();

  // Initialize - check if user is already logged in
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      _user = await _authService.getUserStatus();
    } catch (e) {
      _user = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  // Login
  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.login(username, password);

      if (response['success'] == true && response['user'] != null) {
        _user = User.fromJson(response['user']);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'Login failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      // More detailed error message
      final errorMsg = e.toString();
      if (errorMsg.contains('SocketException') ||
          errorMsg.contains('Connection')) {
        _error =
            'Cannot connect to server. Please check if Django server is running on http://127.0.0.1:8000';
      } else if (errorMsg.contains('401')) {
        _error = 'Invalid username or password';
      } else if (errorMsg.contains('400')) {
        _error = 'Bad request. Please check your input';
      } else {
        _error = 'Login failed: $errorMsg';
      }
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Register
  Future<bool> register({
    required String username,
    required String email,
    required String password,
    required String password2,
    required String firstName,
    required String lastName,
    required String role,
    String? phoneNumber,
    String? address,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.register(
        username: username,
        email: email,
        password: password,
        password2: password2,
        firstName: firstName,
        lastName: lastName,
        role: role,
        phoneNumber: phoneNumber,
        address: address,
      );

      if (response['success'] == true) {
        // Auto-login after registration
        if (response['user'] != null) {
          _user = User.fromJson(response['user']);
        }
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        // Extract specific field errors if available
        if (response['errors'] != null) {
          final errors = response['errors'] as Map<String, dynamic>;
          final errorMessages = <String>[];

          errors.forEach((field, messages) {
            if (messages is List) {
              for (var msg in messages) {
                errorMessages.add('$field: $msg');
              }
            }
          });

          _error = errorMessages.isNotEmpty
              ? errorMessages.join('\n')
              : response['message'] ?? 'Registration failed';
        } else {
          _error = response['message'] ?? 'Registration failed';
        }
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.logout();
    } catch (e) {
      // Ignore errors on logout
    }

    _user = null;
    _isLoading = false;
    notifyListeners();
  }

  // Update profile
  Future<bool> updateProfile({
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
    String? address,
    String? profilePicture,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.updateProfile(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phoneNumber: phoneNumber,
        address: address,
        profilePicture: profilePicture,
      );

      if (response['success'] == true && response['user'] != null) {
        _user = User.fromJson(response['user']);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'Update failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Refresh user data
  Future<void> refreshUser() async {
    try {
      final user = await _authService.getProfile();
      _user = user;
      notifyListeners();
    } catch (e) {
      // Ignore errors
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
