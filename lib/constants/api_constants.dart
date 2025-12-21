import '../config/config.dart';

class ApiConstants {
  // IMPORTANT:
  // Keep all API URLs consistent across the app.
  // If login uses one base URL but other requests use another,
  // session cookies won't be sent and you'll get 401.

  static const String baseUrl = AppConfig.baseUrl;

  // API Endpoints
  static const String loginUrl =
      '${AppConfig.baseUrl}${AppConfig.loginEndpoint}';
  static const String registerUrl =
      '${AppConfig.baseUrl}${AppConfig.registerEndpoint}';
  static const String logoutUrl =
      '${AppConfig.baseUrl}${AppConfig.logoutEndpoint}';
  static const String userStatusUrl =
      '${AppConfig.baseUrl}${AppConfig.userStatusEndpoint}';
  static const String profileUrl =
      '${AppConfig.baseUrl}${AppConfig.profileEndpoint}';
}
