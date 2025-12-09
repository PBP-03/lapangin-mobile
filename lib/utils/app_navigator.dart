import 'package:flutter/material.dart';
import '../models/user.dart';

/// Navigation helper for role-based routing
class AppNavigator {
  /// Navigate to appropriate home page based on user role
  static void navigateToRoleHome(BuildContext context, User user) {
    String route;

    switch (user.role) {
      case 'user':
        route = '/user/home';
        break;
      case 'mitra':
        route = '/mitra/home';
        break;
      case 'admin':
        route = '/admin/home';
        break;
      default:
        route = '/login';
    }

    Navigator.pushReplacementNamed(context, route);
  }

  /// Navigate to role selector (for development/testing)
  static void navigateToRoleSelector(BuildContext context) {
    Navigator.pushReplacementNamed(context, '/role-selector');
  }

  /// Navigate to login and clear navigation stack
  static void navigateToLogin(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  /// Check if user has permission for a specific role
  static bool hasRole(User? user, String requiredRole) {
    if (user == null) return false;
    return user.role == requiredRole;
  }

  /// Check if user has any of the specified roles
  static bool hasAnyRole(User? user, List<String> roles) {
    if (user == null) return false;
    return roles.contains(user.role);
  }
}
