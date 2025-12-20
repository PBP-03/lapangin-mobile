import '../models/venue_model.dart';
import '../config/config.dart';
import 'api_service.dart';

class VenueService {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> getVenues({
    int page = 1,
    int pageSize = 9,
    String? search,
    String? name,
    String? category,
    double? minPrice,
    double? maxPrice,
    String? location,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'page_size': pageSize,
      };

      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (name != null && name.isNotEmpty) queryParams['name'] = name;
      if (category != null && category.isNotEmpty) {
        queryParams['category'] = category;
      }
      if (minPrice != null) queryParams['min_price'] = minPrice;
      if (maxPrice != null) queryParams['max_price'] = maxPrice;
      if (location != null && location.isNotEmpty) {
        queryParams['location'] = location;
      }

      final response = await _apiService.get(
        AppConfig.venuesEndpoint,
        queryParams: queryParams,
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Venue> getVenueDetail(String venueId) async {
    try {
      final response = await _apiService.get(
        '${AppConfig.venueDetailEndpoint}$venueId/',
      );
      return Venue.fromJson(response['data']);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<SportsCategory>> getSportsCategories() async {
    try {
      final response = await _apiService.get(
        AppConfig.sportsCategoriesEndpoint,
      );
      final categories = (response['categories'] as List)
          .map((json) => SportsCategory.fromJson(json))
          .toList();
      return categories;
    } catch (e) {
      rethrow;
    }
  }

  // Mitra endpoints - for venue owners
  Future<Map<String, dynamic>> createVenue({
    required String name,
    required String address,
    String? locationUrl,
    String? contact,
    String? description,
    List<String>? imageUrls,
  }) async {
    try {
      final body = {
        'name': name,
        'address': address,
        if (locationUrl != null) 'location_url': locationUrl,
        if (contact != null) 'contact': contact,
        if (description != null) 'description': description,
        if (imageUrls != null) 'images': imageUrls,
      };

      final response = await _apiService.post(
        AppConfig.venuesEndpoint,
        body: body,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateVenue(
    String venueId, {
    String? name,
    String? address,
    String? locationUrl,
    String? contact,
    String? description,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (address != null) body['address'] = address;
      if (locationUrl != null) body['location_url'] = locationUrl;
      if (contact != null) body['contact'] = contact;
      if (description != null) body['description'] = description;

      final response = await _apiService.put(
        '${AppConfig.venuesEndpoint}$venueId/',
        body: body,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> deleteVenue(String venueId) async {
    try {
      final response = await _apiService.delete(
        '${AppConfig.venuesEndpoint}$venueId/',
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Venue>> getMyVenues() async {
    try {
      final response = await _apiService.get(AppConfig.venuesEndpoint);
      final venues = (response['data'] as List)
          .map((json) => Venue.fromJson(json))
          .toList();
      return venues;
    } catch (e) {
      rethrow;
    }
  }

  // Get venue by ID (public endpoint)
  Future<Venue> getVenueById(String id) async {
    try {
      final response = await _apiService.get(
        '${AppConfig.venueDetailEndpoint}$id/',
      );
      return Venue.fromJson(response['data']);
    } catch (e) {
      rethrow;
    }
  }

  // Verify venue (admin only)
  Future<Map<String, dynamic>> verifyVenue(
    String id, {
    bool approve = true,
    String? rejectionReason,
  }) async {
    try {
      final response = await _apiService.post(
        '${AppConfig.venuesEndpoint}$id/verify/',
        body: {
          'approve': approve,
          if (rejectionReason != null) 'rejection_reason': rejectionReason,
        },
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
