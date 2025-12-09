import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

/// Route guard middleware for protecting routes based on authentication and roles
class RouteGuard {
  /// Check if user is authenticated, redirect to login if not
  static Widget requireAuth(BuildContext context, Widget child) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (!userProvider.isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return child;
  }

  /// Check if user has required role, redirect if not
  static Widget requireRole(
    BuildContext context,
    Widget child,
    String requiredRole, {
    Widget? fallback,
  }) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (!userProvider.isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (userProvider.userRole != requiredRole) {
      return fallback ?? _buildUnauthorizedPage(context);
    }

    return child;
  }

  /// Check if user has any of the required roles
  static Widget requireAnyRole(
    BuildContext context,
    Widget child,
    List<String> requiredRoles, {
    Widget? fallback,
  }) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (!userProvider.isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!requiredRoles.contains(userProvider.userRole)) {
      return fallback ?? _buildUnauthorizedPage(context);
    }

    return child;
  }

  /// Build unauthorized access page
  static Widget _buildUnauthorizedPage(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Unauthorized'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 80, color: Colors.red),
            const SizedBox(height: 24),
            const Text(
              'Access Denied',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'You don\'t have permission to access this page',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text('Go Back'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Example usage in routes:
///
/// routes: {
///   '/user/home': (context) => RouteGuard.requireRole(
///     context,
///     const UserHomePage(),
///     'user',
///   ),
/// }
