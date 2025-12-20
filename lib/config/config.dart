class AppConfig {
  // API Base URL - Change this to your Django backend URL
  static const String baseUrl = 'http://127.0.0.1:8000';

  // For production, use the deployed URL
  // static const String baseUrl = 'https://muhammad-fauzan44-lapangin.pbp.cs.ui.ac.id';

  // API Endpoints
  static const String loginEndpoint = '/api/login/';
  static const String registerEndpoint = '/api/register/';
  static const String logoutEndpoint = '/api/logout/';
  static const String userStatusEndpoint = '/api/user-status/';
  static const String profileEndpoint = '/api/profile/';
  static const String userDashboardEndpoint = '/api/user-dashboard/';

  // Venues
  static const String venuesEndpoint = '/api/public/venues/';
  static const String venueDetailEndpoint = '/api/public/venues/';
  static const String sportsCategoriesEndpoint = '/api/sports-categories/';

  // Courts
  static const String courtsEndpoint = '/api/courts/';

  // Bookings
  static const String bookingsEndpoint = '/api/bookings/';

  // Reviews
  static const String reviewsEndpoint = '/api/venues/';

  // Revenue & Dashboards
  static const String mitraDashboardEndpoint = '/api/mitra-dashboard/';
  static const String adminDashboardEndpoint = '/api/admin-dashboard/';
  static const String mitraListEndpoint = '/api/mitra/';
  static const String mitraEarningsEndpoint = '/api/mitra/earnings/';

  // App Settings
  static const int requestTimeout = 30; // seconds
  static const int pageSize = 9;

  // Build full URL
  static String buildUrl(String endpoint) {
    return '$baseUrl$endpoint';
  }
}
