import '../models/booking_model.dart';
import '../config/config.dart';
import 'api_service.dart';

class BookingService {
  final ApiService _apiService = ApiService();

  Future<Booking> createBooking({
    required String courtId,
    required String sessionId,
    required DateTime bookingDate,
    String? notes,
  }) async {
    try {
      final body = {
        'court': courtId,
        'session': sessionId,
        'booking_date': bookingDate.toIso8601String().split('T')[0],
        if (notes != null) 'notes': notes,
      };

      final response = await _apiService.post(
        AppConfig.bookingsEndpoint,
        body: body,
      );
      return Booking.fromJson(response['booking']);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Booking>> getUserBookings({String? status}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (status != null) queryParams['status'] = status;

      final response = await _apiService.get(
        AppConfig.bookingsEndpoint,
        queryParams: queryParams,
      );

      // Handle nested data structure
      final bookingsData = response['data'] != null
          ? response['data']['bookings']
          : response['bookings'];

      final bookings = (bookingsData as List)
          .map((json) => Booking.fromJson(json))
          .toList();
      return bookings;
    } catch (e) {
      rethrow;
    }
  }

  Future<Booking> getBookingDetail(String bookingId) async {
    try {
      final response = await _apiService.get(
        '${AppConfig.bookingsEndpoint}$bookingId/',
      );
      return Booking.fromJson(response['booking']);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> cancelBooking(
    String bookingId, {
    String? reason,
  }) async {
    try {
      final response = await _apiService.patch(
        '${AppConfig.bookingsEndpoint}$bookingId/',
        body: {
          'booking_status': 'cancelled',
          if (reason != null) 'cancellation_reason': reason,
        },
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateBookingStatus(
    String bookingId,
    String status,
  ) async {
    try {
      final response = await _apiService.patch(
        '${AppConfig.bookingsEndpoint}$bookingId/',
        body: {'booking_status': status},
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createPayment({
    required String bookingId,
    required double amount,
    required String paymentMethod,
    String? transactionId,
    String? paymentProof,
    String? notes,
  }) async {
    try {
      final body = {
        'booking': bookingId,
        'amount': amount,
        'payment_method': paymentMethod,
        if (transactionId != null) 'transaction_id': transactionId,
        if (paymentProof != null) 'payment_proof': paymentProof,
        if (notes != null) 'notes': notes,
      };

      final response = await _apiService.post(
        '${AppConfig.bookingsEndpoint}$bookingId/payment/',
        body: body,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Payment> getPaymentDetail(String bookingId) async {
    try {
      final response = await _apiService.get(
        '${AppConfig.bookingsEndpoint}$bookingId/payment/',
      );
      return Payment.fromJson(response['payment']);
    } catch (e) {
      rethrow;
    }
  }

  // Check available time slots for a court on a specific date
  Future<Map<String, dynamic>> checkAvailability({
    required int courtId,
    required String date,
  }) async {
    try {
      final response = await _apiService.get(
        '${AppConfig.courtsEndpoint}$courtId/availability/',
        queryParams: {'date': date},
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
