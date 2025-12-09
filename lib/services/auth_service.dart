import '../models/user_model.dart';
import '../config/config.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await _apiService.post(
        AppConfig.loginEndpoint,
        body: {'username': username, 'password': password},
      );

      print('[AuthService] Login response keys: ${response.keys}');
      print(
        '[AuthService] Auth token present: ${response.containsKey('auth_token')}',
      );

      // Extract and set auth token if present (for Flutter Web compatibility)
      if (response['auth_token'] != null) {
        await _apiService.setAuthToken(response['auth_token']);
        print(
          '[AuthService] Auth token stored: ${response['auth_token'].substring(0, 20)}...',
        );
      } else {
        print('[AuthService] WARNING: No auth_token in login response!');
      }

      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> register({
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
    try {
      final response = await _apiService.post(
        AppConfig.registerEndpoint,
        body: {
          'username': username,
          'email': email,
          'password1': password,
          'password2': password2,
          'first_name': firstName,
          'last_name': lastName,
          'role': role,
          if (phoneNumber != null) 'phone_number': phoneNumber,
          if (address != null) 'address': address,
        },
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> logout() async {
    try {
      final response = await _apiService.post(AppConfig.logoutEndpoint);
      await _apiService.clearAuth();
      return response;
    } catch (e) {
      await _apiService.clearAuth();
      rethrow;
    }
  }

  Future<User?> getUserStatus() async {
    try {
      final response = await _apiService.get(AppConfig.userStatusEndpoint);
      if (response['authenticated'] == true && response['user'] != null) {
        return User.fromJson(response['user']);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<User> getProfile() async {
    try {
      final response = await _apiService.get(AppConfig.profileEndpoint);
      return User.fromJson(response['user']);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateProfile({
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
    String? address,
    String? profilePicture,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (firstName != null) body['first_name'] = firstName;
      if (lastName != null) body['last_name'] = lastName;
      if (email != null) body['email'] = email;
      if (phoneNumber != null) body['phone_number'] = phoneNumber;
      if (address != null) body['address'] = address;
      if (profilePicture != null) body['profile_picture'] = profilePicture;

      final response = await _apiService.put(
        AppConfig.profileEndpoint,
        body: body,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getUserDashboard() async {
    try {
      final response = await _apiService.get(AppConfig.userDashboardEndpoint);
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
