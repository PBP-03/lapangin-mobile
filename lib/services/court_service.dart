import 'package:flutter/foundation.dart';
import '../models/court_model.dart';
import '../config/config.dart';
import 'api_service.dart';

class CourtService {
  final ApiService _apiService = ApiService();

  Future<List<Court>> getCourts({String? venueId}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (venueId != null) queryParams['venue'] = venueId;

      final response = await _apiService.get(
        AppConfig.courtsEndpoint,
        queryParams: queryParams,
      );

      final courts = (response['courts'] as List)
          .map((json) => Court.fromJson(json))
          .toList();
      return courts;
    } catch (e) {
      rethrow;
    }
  }

  Future<Court> getCourtDetail(int courtId) async {
    try {
      final response = await _apiService.get(
        '${AppConfig.courtsEndpoint}$courtId/',
      );
      return Court.fromJson(response['court']);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<CourtSession>> getCourtSessions(int courtId) async {
    try {
      final response = await _apiService.get(
        '${AppConfig.courtsEndpoint}$courtId/sessions/',
      );
      final sessions = (response['sessions'] as List)
          .map((json) => CourtSession.fromJson(json))
          .toList();
      return sessions;
    } catch (e) {
      rethrow;
    }
  }

  // Mitra endpoints
  Future<Map<String, dynamic>> createCourt({
    required String venueId,
    required String name,
    int? categoryId,
    required double pricePerHour,
    String? description,
    List<String>? imageUrls,
  }) async {
    try {
      final body = {
        'venue': venueId,
        'name': name,
        if (categoryId != null) 'category': categoryId,
        'price_per_hour': pricePerHour,
        if (description != null) 'description': description,
        if (imageUrls != null) 'images': imageUrls,
      };

      final response = await _apiService.post(
        AppConfig.courtsEndpoint,
        body: body,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateCourt(
    int courtId, {
    String? name,
    int? categoryId,
    double? pricePerHour,
    bool? isActive,
    String? description,
    String? maintenanceNotes,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (categoryId != null) body['category'] = categoryId;
      if (pricePerHour != null) body['price_per_hour'] = pricePerHour;
      if (isActive != null) body['is_active'] = isActive;
      if (description != null) body['description'] = description;
      if (maintenanceNotes != null) {
        body['maintenance_notes'] = maintenanceNotes;
      }

      final response = await _apiService.put(
        '${AppConfig.courtsEndpoint}$courtId/',
        body: body,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> deleteCourt(int courtId) async {
    try {
      final response = await _apiService.delete(
        '${AppConfig.courtsEndpoint}$courtId/',
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createSession({
    required int courtId,
    required String sessionName,
    required String startTime,
    required String endTime,
  }) async {
    try {
      final body = {
        'court': courtId,
        'session_name': sessionName,
        'start_time': startTime,
        'end_time': endTime,
      };

      final response = await _apiService.post(
        '${AppConfig.courtsEndpoint}$courtId/sessions/',
        body: body,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> deleteSession(int courtId, int sessionId) async {
    try {
      final response = await _apiService.delete(
        '${AppConfig.courtsEndpoint}$courtId/sessions/$sessionId/',
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Get courts by venue
  Future<List<Court>> getCourtsByVenue(String venueId) async {
    try {
      final response = await _apiService.get(
        '${AppConfig.courtsEndpoint}?venue_id=$venueId',
      );

      if (response['courts'] != null) {
        final List<dynamic> data = response['courts'];
        return data.map((json) => Court.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching courts by venue: $e');
      return [];
    }
  }

  // Get available sessions for a court on a specific date
  Future<List<CourtSession>> getAvailableSessions(
    int courtId,
    DateTime date,
  ) async {
    try {
      final dateStr =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final response = await _apiService.get(
        '${AppConfig.courtsEndpoint}$courtId/sessions/?date=$dateStr',
      );

      if (response['sessions'] != null) {
        final List<dynamic> data = response['sessions'];
        return data.map((json) => CourtSession.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching available sessions: $e');
      return [];
    }
  }
}
