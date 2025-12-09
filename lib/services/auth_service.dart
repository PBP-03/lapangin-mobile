import 'dart:convert';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../constants/api_constants.dart';
import '../models/user.dart';

class AuthService {
  final CookieRequest request;

  AuthService(this.request);

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await request.postJson(
        ApiConstants.loginUrl,
        jsonEncode({'username': username, 'password': password}),
      );

      if (response['success'] == true) {
        final userData = response['user'];
        final user = User.fromJson(userData);

        return {
          'success': true,
          'message': response['message'] ?? 'Login successful!',
          'user': user,
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'Login failed',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> data) async {
    try {
      final response = await request.postJson(
        ApiConstants.registerUrl,
        jsonEncode(data),
      );

      return response;
    } catch (e) {
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }

  Future<bool> logout() async {
    try {
      final response = await request.logout(ApiConstants.logoutUrl);
      return response['success'] ?? false;
    } catch (e) {
      return false;
    }
  }

  bool isLoggedIn() {
    return request.loggedIn;
  }
}
