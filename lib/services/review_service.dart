import '../models/review_model.dart';
import '../config/config.dart';
import 'api_service.dart';

class ReviewService {
  final ApiService _apiService = ApiService();

  Future<List<Review>> getVenueReviews(String venueId, {int page = 1}) async {
    try {
      final response = await _apiService.get(
        '${AppConfig.reviewsEndpoint}$venueId/reviews/',
        queryParams: {'page': page},
      );
      final data = response['data'] ?? response;
      final reviews = (data['reviews'] as List)
          .map((json) => Review.fromJson(json))
          .toList();
      return reviews;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createVenueReview({
    required String venueId,
    required int rating,
    String? comment,
  }) async {
    try {
      final body = <String, dynamic>{
        'rating': rating,
        'comment': comment ?? '',
      };

      final response = await _apiService.post(
        '${AppConfig.reviewsEndpoint}$venueId/reviews/',
        body: body,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateReview(
    String reviewId, {
    int? rating,
    String? comment,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (rating != null) body['rating'] = rating;
      if (comment != null) body['comment'] = comment;

      final response = await _apiService.put(
        '/api/reviews/$reviewId/',
        body: body,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> deleteReview(String reviewId) async {
    try {
      final response = await _apiService.delete('/api/reviews/$reviewId/');
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
