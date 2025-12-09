class ApiConstants {
  // Change this to your Django backend URL
  // For local development:
  // - Android emulator: 'http://10.0.2.2:8000'
  // - iOS simulator: 'http://localhost:8000'
  // - Physical device: 'http://YOUR_LOCAL_IP:8000' (e.g., 'http://192.168.1.100:8000')
  // For production: 'https://your-domain.com'

  static const String baseUrl = 'https://muhammad-fauzan44-lapangin.pbp.cs.ui.ac.id';

  // API Endpoints
  static const String loginUrl = '$baseUrl/api/login/';
  static const String registerUrl = '$baseUrl/api/register/';
  static const String logoutUrl = '$baseUrl/api/logout/';
  static const String userStatusUrl = '$baseUrl/api/user-status/';
  static const String profileUrl = '$baseUrl/api/profile/';
}
