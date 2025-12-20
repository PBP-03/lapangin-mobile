class Court {
  final int id;
  final String venueId;
  final String name;
  final int? categoryId;
  final String? categoryName;
  final String? sportsCategory;
  final double pricePerHour;
  final bool isActive;
  final String? maintenanceNotes;
  final String? description;
  final List<String> images;

  Court({
    required this.id,
    required this.venueId,
    required this.name,
    this.categoryId,
    this.categoryName,
    this.sportsCategory,
    required this.pricePerHour,
    this.isActive = true,
    this.maintenanceNotes,
    this.description,
    this.images = const [],
  });

  factory Court.fromJson(Map<String, dynamic> json) {
    return Court(
      id: json['id'] as int,
      venueId: json['venue'] as String? ?? json['venue_id'] as String,
      name: json['name'] as String,
      categoryId: json['category'] as int?,
      categoryName: json['category_name'] as String?,
      sportsCategory: json['sports_category'] as String?,
      pricePerHour: (json['price_per_hour'] as num).toDouble(),
      isActive: json['is_active'] as bool? ?? true,
      maintenanceNotes: json['maintenance_notes'] as String?,
      description: json['description'] as String?,
      images: (json['images'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'venue': venueId,
      'name': name,
      'category': categoryId,
      'category_name': categoryName,
      'price_per_hour': pricePerHour,
      'is_active': isActive,
      'maintenance_notes': maintenanceNotes,
      'description': description,
      'images': images,
    };
  }

  String get primaryImage => images.isNotEmpty ? images.first : '';
}

class CourtSession {
  final int id;
  final int courtId;
  final String sessionName;
  final String startTime; // Format: "HH:mm:ss"
  final String endTime; // Format: "HH:mm:ss"
  final bool isActive;

  CourtSession({
    required this.id,
    required this.courtId,
    required this.sessionName,
    required this.startTime,
    required this.endTime,
    this.isActive = true,
  });

  factory CourtSession.fromJson(Map<String, dynamic> json) {
    return CourtSession(
      id: json['id'] as int,
      courtId: json['court'] as int? ?? json['court_id'] as int,
      sessionName: json['session_name'] as String,
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'court': courtId,
      'session_name': sessionName,
      'start_time': startTime,
      'end_time': endTime,
      'is_active': isActive,
    };
  }

  String get timeRange => '$startTime - $endTime';
}

class CourtImage {
  final int id;
  final int courtId;
  final String imageUrl;
  final bool isPrimary;
  final String? caption;
  final DateTime uploadedAt;

  CourtImage({
    required this.id,
    required this.courtId,
    required this.imageUrl,
    this.isPrimary = false,
    this.caption,
    required this.uploadedAt,
  });

  factory CourtImage.fromJson(Map<String, dynamic> json) {
    return CourtImage(
      id: json['id'] as int,
      courtId: json['court'] as int? ?? json['court_id'] as int,
      imageUrl: json['image_url'] as String,
      isPrimary: json['is_primary'] as bool? ?? false,
      caption: json['caption'] as String?,
      uploadedAt: DateTime.parse(json['uploaded_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'court': courtId,
      'image_url': imageUrl,
      'is_primary': isPrimary,
      'caption': caption,
      'uploaded_at': uploadedAt.toIso8601String(),
    };
  }
}
