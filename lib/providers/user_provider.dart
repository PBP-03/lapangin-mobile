import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

class UserProvider extends ChangeNotifier {
  User? _user;

  User? get user => _user;

  bool get isLoggedIn => _user != null;

  String? get userRole => _user?.role;

  bool get isUser => _user?.role == 'user';
  bool get isMitra => _user?.role == 'mitra';
  bool get isAdmin => _user?.role == 'admin';

  void setUser(User user) {
    _user = user;
    notifyListeners();
  }

  void logout() {
    _user = null;
    notifyListeners();
  }

  void updateUser(User user) {
    _user = user;
    notifyListeners();
  }

  // Empty initialize method for compatibility
  Future<void> initialize() async {
    // No-op: the login page handles authentication
  }
}
