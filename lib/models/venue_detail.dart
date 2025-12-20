// To parse this JSON data, do
//
//     final venueDetail = venueDetailFromJson(jsonString);

import 'dart:convert';

VenueDetailResponse venueDetailResponseFromJson(String str) =>
    VenueDetailResponse.fromJson(json.decode(str));

String venueDetailResponseToJson(VenueDetailResponse data) =>
    json.encode(data.toJson());

class VenueDetailResponse {
  final String status;
  final VenueDetail data;

  VenueDetailResponse({required this.status, required this.data});

  factory VenueDetailResponse.fromJson(Map<String, dynamic> json) =>
      VenueDetailResponse(
        status: json["status"],
        data: VenueDetail.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {"status": status, "data": data.toJson()};
}

class VenueDetail {
  final String id;
  final String name;
  final String address;
  final String? locationUrl;
  final String? contact;
  final String? description;
  final int numberOfCourts;
  final List<String> images;
  final List<VenueFacility> facilities;
  final List<Court> courts;
  final double avgRating;
  final int ratingCount;
  final List<Review> reviews;

  VenueDetail({
    required this.id,
    required this.name,
    required this.address,
    this.locationUrl,
    this.contact,
    this.description,
    required this.numberOfCourts,
    required this.images,
    required this.facilities,
    required this.courts,
    required this.avgRating,
    required this.ratingCount,
    required this.reviews,
  });

  factory VenueDetail.fromJson(Map<String, dynamic> json) => VenueDetail(
    id: json["id"],
    name: json["name"],
    address: json["address"],
    locationUrl: json["location_url"],
    contact: json["contact"],
    description: json["description"],
    numberOfCourts: json["number_of_courts"],
    images: List<String>.from(json["images"].map((x) => x)),
    facilities: List<VenueFacility>.from(
      json["facilities"].map((x) => VenueFacility.fromJson(x)),
    ),
    courts: List<Court>.from(json["courts"].map((x) => Court.fromJson(x))),
    avgRating: (json["avg_rating"] is int)
        ? (json["avg_rating"] as int).toDouble()
        : (json["avg_rating"] as num).toDouble(),
    ratingCount: json["rating_count"],
    reviews: List<Review>.from(json["reviews"].map((x) => Review.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "address": address,
    "location_url": locationUrl,
    "contact": contact,
    "description": description,
    "number_of_courts": numberOfCourts,
    "images": List<dynamic>.from(images.map((x) => x)),
    "facilities": List<dynamic>.from(facilities.map((x) => x.toJson())),
    "courts": List<dynamic>.from(courts.map((x) => x.toJson())),
    "avg_rating": avgRating,
    "rating_count": ratingCount,
    "reviews": List<dynamic>.from(reviews.map((x) => x.toJson())),
  };
}

class VenueFacility {
  final String name;
  final String? icon;

  VenueFacility({required this.name, this.icon});

  factory VenueFacility.fromJson(Map<String, dynamic> json) =>
      VenueFacility(name: json["name"], icon: json["icon"]);

  Map<String, dynamic> toJson() => {"name": name, "icon": icon};
}

class Court {
  final int id;
  final String name;
  final bool isActive;
  final double pricePerHour;
  final List<CourtSession> sessions;

  Court({
    required this.id,
    required this.name,
    required this.isActive,
    required this.pricePerHour,
    required this.sessions,
  });

  factory Court.fromJson(Map<String, dynamic> json) => Court(
    id: json["id"],
    name: json["name"],
    isActive: json["is_active"],
    pricePerHour: (json["price_per_hour"] is int)
        ? (json["price_per_hour"] as int).toDouble()
        : (json["price_per_hour"] as num).toDouble(),
    sessions: List<CourtSession>.from(
      json["sessions"].map((x) => CourtSession.fromJson(x)),
    ),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "is_active": isActive,
    "price_per_hour": pricePerHour,
    "sessions": List<dynamic>.from(sessions.map((x) => x.toJson())),
  };
}

class CourtSession {
  final int id;
  final String sessionName;
  final String startTime;
  final String endTime;
  final bool isActive;

  CourtSession({
    required this.id,
    required this.sessionName,
    required this.startTime,
    required this.endTime,
    required this.isActive,
  });

  factory CourtSession.fromJson(Map<String, dynamic> json) => CourtSession(
    id: json["id"],
    sessionName: json["session_name"],
    startTime: json["start_time"],
    endTime: json["end_time"],
    isActive: json["is_active"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "session_name": sessionName,
    "start_time": startTime,
    "end_time": endTime,
    "is_active": isActive,
  };
}

class Review {
  final String user;
  final int rating;
  final String? comment;
  final String? createdAt;

  Review({
    required this.user,
    required this.rating,
    this.comment,
    this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) => Review(
    user: json["user"],
    rating: json["rating"],
    comment: json["comment"],
    createdAt: json["created_at"],
  );

  Map<String, dynamic> toJson() => {
    "user": user,
    "rating": rating,
    "comment": comment,
    "created_at": createdAt,
  };
}
