import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import '../models/earnings_model.dart';
import '../constants/api_constants.dart';

class AdminEarningsService {
  final CookieRequest request;

  AdminEarningsService(this.request);

  /// Get all mitra earnings
  /// Endpoint: GET /api/mitra/earnings/
  Future<List<EarningsModel>> getAllMitraEarnings() async {
    try {
      final response = await request.get(
        '${ApiConstants.baseUrl}/api/mitra/earnings/',
      );

      if (response['status'] == 'ok') {
        final List<dynamic> data = response['data'] ?? [];
        return data.map((json) => EarningsModel.fromJson(json)).toList();
      } else {
        throw Exception(response['message'] ?? 'Failed to load earnings');
      }
    } catch (e) {
      throw Exception('Error fetching earnings: $e');
    }
  }

  /// Get detailed earnings and transactions for a specific mitra
  /// Endpoint: GET /api/mitra/<mitra_id>/earnings/
  Future<MitraEarningsDetail> getMitraEarningsDetail(String mitraId) async {
    try {
      final response = await request.get(
        '${ApiConstants.baseUrl}/api/mitra/$mitraId/earnings/',
      );

      if (response['status'] == 'ok') {
        return MitraEarningsDetail.fromJson(response['data']);
      } else {
        throw Exception(
          response['message'] ?? 'Failed to load mitra earnings detail',
        );
      }
    } catch (e) {
      throw Exception('Error fetching mitra earnings detail: $e');
    }
  }

  /// Get all refunded transactions
  /// Endpoint: GET /api/refunds/
  Future<List<RefundModel>> getRefunds() async {
    try {
      final response = await request.get('${ApiConstants.baseUrl}/api/refunds/');
      
      if (response['status'] == 'ok') {
        final List<dynamic> data = response['data'] ?? [];
        return data.map((json) => RefundModel.fromJson(json)).toList();
      } else {
        throw Exception(response['message'] ?? 'Failed to load refunds');
      }
    } catch (e) {
      throw Exception('Error fetching refunds: $e');
    }
  }

  /// Process a refund for a transaction
  /// Endpoint: POST /api/refunds/create/
  Future<void> createRefund(String pendapatanId, String reason) async {
    try {
      // Ensure URL has trailing slash - Django is picky about this
      final url = '${ApiConstants.baseUrl}/api/refunds/create/';
      debugPrint('=== CREATE REFUND START ===');
      debugPrint('URL: $url');
      debugPrint('Pendapatan ID: $pendapatanId');
      debugPrint('Reason: $reason');
      
      // Try with postJson which sets proper Content-Type headers
      final response = await request.postJson(
        url,
        jsonEncode({
          'pendapatan_id': pendapatanId,
          'reason': reason,
        }),
      );
      
      debugPrint('Response type: ${response.runtimeType}');
      debugPrint('Response: $response');
      
      // Handle different response types
      if (response is Map) {
        if (response['status'] == 'error') {
          throw Exception(response['message'] ?? 'Failed to process refund');
        }
        if (response['status'] != 'ok') {
          throw Exception('Unexpected response status: ${response['status']}');
        }
        debugPrint('Refund processed successfully!');
      } else if (response is String) {
        debugPrint('Response is String (likely HTML error): ${response.substring(0, 200)}');
        // If response is HTML string
        throw Exception('Server returned HTML error. This may be a CSRF or authentication issue.');
      } else {
        throw Exception('Invalid response format: ${response.runtimeType}');
      }
    } on FormatException catch (e) {
      debugPrint('FormatException: $e');
      throw Exception('Server returned HTML instead of JSON. Check backend CSRF settings or try logging in again.');
    } catch (e) {
      debugPrint('Error in createRefund: $e');
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('Error processing refund: $e');
    }
  }

  /// Cancel a refund and restore transaction to paid status
  /// Endpoint: DELETE /api/refunds/<pendapatan_id>/cancel/
  Future<void> cancelRefund(String pendapatanId) async {
    try {
      final response = await request.post(
        '${ApiConstants.baseUrl}/api/refunds/$pendapatanId/cancel/',
        {},
      );
      
      if (response['status'] != 'ok') {
        throw Exception(response['message'] ?? 'Failed to cancel refund');
      }
    } catch (e) {
      throw Exception('Error cancelling refund: $e');
    }
  }
}
