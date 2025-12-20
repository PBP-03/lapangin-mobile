import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/config.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _authToken;

  // Auth token management
  Future<void> _saveAuthToken(String? token) async {
    print(
      '[ApiService] _saveAuthToken called with token: ${token?.substring(0, 20) ?? 'NULL'}...',
    );
    final prefs = await SharedPreferences.getInstance();
    if (token != null) {
      final success = await prefs.setString('auth_token', token);
      print('[ApiService] SharedPreferences setString result: $success');
      _authToken = token;
      print(
        '[ApiService] Auth token saved to memory and storage: ${token.substring(0, 20)}...',
      );
    } else {
      print('[ApiService] Token is null, not saving');
    }
  }

  Future<void> _loadAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('auth_token');
    if (_authToken != null) {
      print(
        '[ApiService] Auth token loaded from storage: ${_authToken!.substring(0, 20)}...',
      );
    } else {
      print('[ApiService] No auth token found in storage');
    }
  }

  Future<void> clearAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    _authToken = null;
    print('[ApiService] Auth token cleared');
  }

  // Set auth token from login response
  Future<void> setAuthToken(String token) async {
    await _saveAuthToken(token);
  }

  // No longer extracting cookies - using Authorization tokens instead

  // Build headers with auth token
  Map<String, String> _buildHeaders({bool includeContentType = true}) {
    final headers = <String, String>{};

    if (includeContentType) {
      headers['Content-Type'] = 'application/json';
    }

    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
      print('[ApiService] Adding Authorization header with token');
    } else {
      print('[ApiService] No auth token available');
    }

    return headers;
  }

  // Generic GET request
  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, dynamic>? queryParams,
  }) async {
    await _loadAuthToken();

    var uri = Uri.parse(AppConfig.buildUrl(endpoint));
    if (queryParams != null && queryParams.isNotEmpty) {
      uri = uri.replace(
        queryParameters: queryParams.map(
          (key, value) => MapEntry(key, value.toString()),
        ),
      );
    }

    try {
      final response = await http
          .get(uri, headers: _buildHeaders(includeContentType: false))
          .timeout(Duration(seconds: AppConfig.requestTimeout));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return json.decode(response.body);
      } else {
        throw ApiException(
          statusCode: response.statusCode,
          message: _extractErrorMessage(response),
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        statusCode: 0,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  // Generic POST request
  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    await _loadAuthToken();

    final uri = Uri.parse(AppConfig.buildUrl(endpoint));

    try {
      final response = await http
          .post(
            uri,
            headers: _buildHeaders(),
            body: body != null ? json.encode(body) : null,
          )
          .timeout(Duration(seconds: AppConfig.requestTimeout));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return json.decode(response.body);
      } else {
        throw ApiException(
          statusCode: response.statusCode,
          message: _extractErrorMessage(response),
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        statusCode: 0,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  // Generic PUT request
  Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    await _loadAuthToken();

    final uri = Uri.parse(AppConfig.buildUrl(endpoint));

    try {
      final response = await http
          .put(
            uri,
            headers: _buildHeaders(),
            body: body != null ? json.encode(body) : null,
          )
          .timeout(Duration(seconds: AppConfig.requestTimeout));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return json.decode(response.body);
      } else {
        throw ApiException(
          statusCode: response.statusCode,
          message: _extractErrorMessage(response),
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        statusCode: 0,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  // Generic PATCH request
  Future<Map<String, dynamic>> patch(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    await _loadAuthToken();

    final uri = Uri.parse(AppConfig.buildUrl(endpoint));

    try {
      final response = await http
          .patch(
            uri,
            headers: _buildHeaders(),
            body: body != null ? json.encode(body) : null,
          )
          .timeout(Duration(seconds: AppConfig.requestTimeout));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return json.decode(response.body);
      } else {
        throw ApiException(
          statusCode: response.statusCode,
          message: _extractErrorMessage(response),
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        statusCode: 0,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  // Generic DELETE request
  Future<Map<String, dynamic>> delete(String endpoint) async {
    await _loadAuthToken();

    final uri = Uri.parse(AppConfig.buildUrl(endpoint));

    try {
      final response = await http
          .delete(uri, headers: _buildHeaders())
          .timeout(Duration(seconds: AppConfig.requestTimeout));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isNotEmpty) {
          return json.decode(response.body);
        }
        return {'success': true};
      } else {
        throw ApiException(
          statusCode: response.statusCode,
          message: _extractErrorMessage(response),
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        statusCode: 0,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  String _extractErrorMessage(http.Response response) {
    try {
      final data = json.decode(response.body);
      if (data is Map && data.containsKey('message')) {
        return data['message'];
      }
      if (data is Map && data.containsKey('error')) {
        return data['error'];
      }
      return 'Request failed with status ${response.statusCode}';
    } catch (e) {
      return 'Request failed with status ${response.statusCode}';
    }
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException({required this.statusCode, required this.message});

  @override
  String toString() => message;
}
