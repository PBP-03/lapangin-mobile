class SportsCategory {
  final int? id;
  final String name; // 'FUTSAL', 'BADMINTON', etc.
  final String? description;
  final String? icon;

  SportsCategory({this.id, required this.name, this.description, this.icon});

  factory SportsCategory.fromJson(Map<String, dynamic> json) {
    return SportsCategory(
      id: json['id'] as int?,
      name: json['name'] as String,
      description: json['description'] as String?,
      icon: json['icon'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'description': description, 'icon': icon};
  }

  String get displayName {
    // Convert from 'FUTSAL' to 'Futsal'
    if (name.isEmpty) return '';
    return name[0].toUpperCase() + name.substring(1).toLowerCase();
  }
}

class Facility {
  final int? id;
  final String name;
  final String? icon;
  final String? description;

  Facility({this.id, required this.name, this.icon, this.description});

  factory Facility.fromJson(Map<String, dynamic> json) {
    return Facility(
      id: json['id'] as int?,
      name: json['name'] as String,
      icon: json['icon'] as String?,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'icon': icon, 'description': description};
  }
}

class Venue {
  final String id;
  final String name;
  final String? ownerId;
  final String address;
  final String? locationUrl;
  final String? contact;
  final String? description;
  final int numberOfCourts;
  final String verificationStatus; // 'pending', 'approved', 'rejected'
  final String? verifiedBy;
  final DateTime? verificationDate;
  final String? rejectionReason;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<String> images;
  final double? averageRating;
  final List<String> categories;
  final double? averagePrice;
  final int totalReviews;
  final String? phoneNumber;
  final String? openingTime;
  final String? closingTime;
  final List<Facility> facilities;
  final List<SportsCategory> sportsCategories;
  final List<dynamic>
  courts; // Store courts as dynamic to avoid circular dependency

  Venue({
    required this.id,
    required this.name,
    this.ownerId,
    required this.address,
    this.locationUrl,
    this.contact,
    this.description,
    required this.numberOfCourts,
    required this.verificationStatus,
    this.verifiedBy,
    this.verificationDate,
    this.rejectionReason,
    this.createdAt,
    this.updatedAt,
    this.images = const [],
    this.averageRating,
    this.categories = const [],
    this.averagePrice,
    this.totalReviews = 0,
    this.phoneNumber,
    this.openingTime,
    this.closingTime,
    this.facilities = const [],
    this.sportsCategories = const [],
    this.courts = const [],
  });

  factory Venue.fromJson(Map<String, dynamic> json) {
    List<String> parseImageUrls(dynamic raw) {
      if (raw is! List) return [];

      final List<Map<String, dynamic>> mapped = [];
      final List<String> plain = [];

      for (final item in raw) {
        if (item is String) {
          if (item.trim().isNotEmpty) plain.add(item);
          continue;
        }
        if (item is Map) {
          final map = Map<String, dynamic>.from(item);
          mapped.add(map);
          continue;
        }
      }

      if (mapped.isEmpty) return plain;

      mapped.sort((a, b) {
        final bool aPrimary = (a['is_primary'] as bool?) ?? false;
        final bool bPrimary = (b['is_primary'] as bool?) ?? false;
        if (aPrimary == bPrimary) return 0;
        return aPrimary ? -1 : 1;
      });

      final urls = <String>[];
      for (final m in mapped) {
        final dynamic url = m['url'] ?? m['image_url'] ?? m['image'];
        final s = url?.toString() ?? '';
        if (s.trim().isNotEmpty) urls.add(s);
      }
      return urls;
    }

    // Handle category field - can be string or list
    List<String> categoriesList = [];
    if (json['category'] != null) {
      if (json['category'] is String) {
        final catString = json['category'] as String;
        categoriesList = catString.isNotEmpty
            ? catString.split(',').map((s) => s.trim()).toList()
            : [];
      }
    } else if (json['categories'] != null) {
      categoriesList =
          (json['categories'] as List<dynamic>?)?.cast<String>() ?? [];
    }

    return Venue(
      id: json['id'] as String,
      name: json['name'] as String,
      ownerId: json['owner'] as String? ?? json['owner_id'] as String? ?? '',
      address: json['address'] as String? ?? '',
      locationUrl: json['location_url'] as String?,
      contact: json['contact'] as String?,
      description: json['description'] as String?,
      numberOfCourts: json['number_of_courts'] as int? ?? 0,
      verificationStatus: json['verification_status'] as String? ?? 'approved',
      verifiedBy: json['verified_by'] as String?,
      verificationDate: json['verification_date'] != null
          ? DateTime.tryParse(json['verification_date'] as String)
          : null,
      rejectionReason: json['rejection_reason'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String) ?? DateTime.now()
          : DateTime.now(),
      images: parseImageUrls(json['images']),
      averageRating:
          (json['avg_rating'] as num?)?.toDouble() ??
          (json['average_rating'] as num?)?.toDouble(),
      categories: categoriesList,
      averagePrice:
          (json['price_per_hour'] as num?)?.toDouble() ??
          (json['average_price'] as num?)?.toDouble(),
      totalReviews:
          json['rating_count'] as int? ?? json['total_reviews'] as int? ?? 0,
      phoneNumber: json['phone_number'] as String?,
      openingTime: json['opening_time'] as String?,
      closingTime: json['closing_time'] as String?,
      facilities:
          (json['facilities'] as List<dynamic>?)
              ?.whereType<Map>()
              .map((f) => Facility.fromJson(Map<String, dynamic>.from(f)))
              .toList() ??
          [],
      sportsCategories:
          (json['sports_categories'] as List<dynamic>?)
              ?.whereType<Map>()
              .map((c) => SportsCategory.fromJson(Map<String, dynamic>.from(c)))
              .toList() ??
          [],
      courts: (json['courts'] as List<dynamic>?)?.toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'owner': ownerId,
      'address': address,
      'location_url': locationUrl,
      'contact': contact,
      'description': description,
      'number_of_courts': numberOfCourts,
      'verification_status': verificationStatus,
      'verified_by': verifiedBy,
      'verification_date': verificationDate?.toIso8601String(),
      'rejection_reason': rejectionReason,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'images': images,
      'average_rating': averageRating,
      'categories': categories,
      'average_price': averagePrice,
    };
  }

  bool get isVerified => verificationStatus == 'approved';
  bool get isPending => verificationStatus == 'pending';
  bool get isRejected => verificationStatus == 'rejected';

  String get primaryImage => images.isNotEmpty ? images.first : '';
}

class VenueImage {
  final int id;
  final String venueId;
  final String imageUrl;
  final bool isPrimary;
  final String? caption;
  final DateTime uploadedAt;

  VenueImage({
    required this.id,
    required this.venueId,
    required this.imageUrl,
    this.isPrimary = false,
    this.caption,
    required this.uploadedAt,
  });

  factory VenueImage.fromJson(Map<String, dynamic> json) {
    return VenueImage(
      id: json['id'] as int,
      venueId: json['venue'] as String? ?? json['venue_id'] as String,
      imageUrl: json['image_url'] as String,
      isPrimary: json['is_primary'] as bool? ?? false,
      caption: json['caption'] as String?,
      uploadedAt: DateTime.parse(json['uploaded_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'venue': venueId,
      'image_url': imageUrl,
      'is_primary': isPrimary,
      'caption': caption,
      'uploaded_at': uploadedAt.toIso8601String(),
    };
  }
}
