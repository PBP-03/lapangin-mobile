// To parse this JSON data, do
//
//     final venueList = venueListFromJson(jsonString);

import 'dart:convert';

VenueListResponse venueListResponseFromJson(String str) =>
    VenueListResponse.fromJson(json.decode(str));

String venueListResponseToJson(VenueListResponse data) =>
    json.encode(data.toJson());

class VenueListResponse {
  final String status;
  final List<Venue> data;
  final Pagination pagination;

  VenueListResponse({
    required this.status,
    required this.data,
    required this.pagination,
  });

  factory VenueListResponse.fromJson(Map<String, dynamic> json) =>
      VenueListResponse(
        status: json["status"],
        data: List<Venue>.from(json["data"].map((x) => Venue.fromJson(x))),
        pagination: Pagination.fromJson(json["pagination"]),
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
    "pagination": pagination.toJson(),
  };
}

class Venue {
  final String id;
  final String name;
  final String category;
  final String? categoryIcon;
  final String address;
  final String? locationUrl;
  final String? contact;
  final double pricePerHour;
  final int numberOfCourts;
  final List<String> images;
  final double avgRating;
  final int ratingCount;
  final List<Facility> facilities;

  Venue({
    required this.id,
    required this.name,
    required this.category,
    this.categoryIcon,
    required this.address,
    this.locationUrl,
    this.contact,
    required this.pricePerHour,
    required this.numberOfCourts,
    required this.images,
    required this.avgRating,
    required this.ratingCount,
    required this.facilities,
  });

  factory Venue.fromJson(Map<String, dynamic> json) => Venue(
    id: json["id"],
    name: json["name"],
    category: json["category"] ?? '',
    categoryIcon: json["category_icon"],
    address: json["address"],
    locationUrl: json["location_url"],
    contact: json["contact"],
    pricePerHour: (json["price_per_hour"] is int)
        ? (json["price_per_hour"] as int).toDouble()
        : (json["price_per_hour"] as num).toDouble(),
    numberOfCourts: json["number_of_courts"],
    images: List<String>.from(json["images"].map((x) => x)),
    avgRating: (json["avg_rating"] is int)
        ? (json["avg_rating"] as int).toDouble()
        : (json["avg_rating"] as num).toDouble(),
    ratingCount: json["rating_count"],
    facilities: List<Facility>.from(
      json["facilities"].map((x) => Facility.fromJson(x)),
    ),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "category": category,
    "category_icon": categoryIcon,
    "address": address,
    "location_url": locationUrl,
    "contact": contact,
    "price_per_hour": pricePerHour,
    "number_of_courts": numberOfCourts,
    "images": List<dynamic>.from(images.map((x) => x)),
    "avg_rating": avgRating,
    "rating_count": ratingCount,
    "facilities": List<dynamic>.from(facilities.map((x) => x.toJson())),
  };
}

class Facility {
  final String name;
  final String? icon;

  Facility({required this.name, this.icon});

  factory Facility.fromJson(Map<String, dynamic> json) =>
      Facility(name: json["name"], icon: json["icon"]);

  Map<String, dynamic> toJson() => {"name": name, "icon": icon};
}

class Pagination {
  final int page;
  final int pageSize;
  final int totalCount;
  final int totalPages;

  Pagination({
    required this.page,
    required this.pageSize,
    required this.totalCount,
    required this.totalPages,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
    page: json["page"],
    pageSize: json["page_size"],
    totalCount: json["total_count"],
    totalPages: json["total_pages"],
  );

  Map<String, dynamic> toJson() => {
    "page": page,
    "page_size": pageSize,
    "total_count": totalCount,
    "total_pages": totalPages,
  };
}
