import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../constants/api_constants.dart';
import '../models/mitra_model.dart';
import '../models/venue_model.dart';

class AdminMitraService {
  final CookieRequest request;

  AdminMitraService(this.request);

  // Get all mitras
  Future<List<MitraModel>> getAllMitra() async {
    try {
      final response = await request.get('${ApiConstants.baseUrl}/api/mitra/');

      if (response['status'] == 'ok') {
        final List data = response['data'] ?? [];
        return data.map((json) => MitraModel.fromJson(json)).toList();
      } else {
        throw Exception(response['message'] ?? 'Failed to load mitra list');
      }
    } catch (e) {
      throw Exception('Error fetching mitra: $e');
    }
  }

  // Get mitra venues detail
  Future<Map<String, dynamic>> getMitraVenues(String mitraId) async {
    try {
      final response = await request.get(
        '${ApiConstants.baseUrl}/api/mitra/$mitraId/venues/',
      );

      if (response['status'] == 'ok') {
        final data = response['data'];
        final mitra = data['mitra'];
        final List venuesList = data['venues'] ?? [];

        return {
          'mitra': mitra,
          'venues': venuesList
              .map((json) => VenueModel.fromJson(json))
              .toList(),
        };
      } else {
        throw Exception(response['message'] ?? 'Failed to load venue details');
      }
    } catch (e) {
      throw Exception('Error fetching mitra venues: $e');
    }
  }

  // Update mitra status (approve/reject)
  Future<Map<String, dynamic>> updateMitraStatus(
    String mitraId,
    String status, {
    String? rejectionReason,
  }) async {
    try {
      final response = await request
          .postJson('${ApiConstants.baseUrl}/api/mitra/$mitraId/', {
            'status': status,
            if (rejectionReason != null) 'rejection_reason': rejectionReason,
          });

      if (response['status'] == 'ok') {
        return response;
      } else {
        throw Exception(response['message'] ?? 'Failed to update mitra status');
      }
    } catch (e) {
      throw Exception('Error updating mitra status: $e');
    }
  }

  // Update venue status (approve/reject) - ENDPOINT BELUM ADA DI BACKEND
  // Akan error sementara sampai backend membuat endpoint ini
  Future<Map<String, dynamic>> updateVenueStatus(
    String venueId,
    String status, {
    String? rejectionReason,
  }) async {
    try {
      final response = await request
          .postJson('${ApiConstants.baseUrl}/api/venues/$venueId/status/', {
            'status': status,
            if (rejectionReason != null) 'rejection_reason': rejectionReason,
          });

      if (response['status'] == 'ok') {
        return response;
      } else {
        throw Exception(response['message'] ?? 'Failed to update venue status');
      }
    } catch (e) {
      throw Exception('Error updating venue status: $e');
    }
  }
}
