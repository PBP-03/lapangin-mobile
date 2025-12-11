class VenueImageModel {
  final int id;
  final String url;
  final bool isPrimary;
  final String caption;

  VenueImageModel({
    required this.id,
    required this.url,
    required this.isPrimary,
    this.caption = '',
  });

  factory VenueImageModel.fromJson(Map<String, dynamic> json) {
    return VenueImageModel(
      id: json['id'] ?? 0,
      url: json['url'] ?? '',
      isPrimary: json['is_primary'] ?? false,
      caption: json['caption'] ?? '',
    );
  }
}

class CourtCategory {
  final String code;
  final String displayName;

  CourtCategory({required this.code, required this.displayName});

  factory CourtCategory.fromJson(Map<String, dynamic> json) {
    return CourtCategory(
      code: json['code'] ?? '',
      displayName: json['display_name'] ?? '',
    );
  }
}

class VenueCourt {
  final int id;
  final String name;
  final double pricePerHour;
  final String description;
  final String category;
  final bool isActive;

  VenueCourt({
    required this.id,
    required this.name,
    required this.pricePerHour,
    required this.description,
    required this.category,
    required this.isActive,
  });

  factory VenueCourt.fromJson(Map<String, dynamic> json) {
    double price = 0.0;
    if (json['price_per_hour'] != null) {
      if (json['price_per_hour'] is String) {
        price = double.tryParse(json['price_per_hour']) ?? 0.0;
      } else if (json['price_per_hour'] is num) {
        price = json['price_per_hour'].toDouble();
      }
    }

    return VenueCourt(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      pricePerHour: price,
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      isActive: json['is_active'] ?? true,
    );
  }
}

class VenueModel {
  final String id;
  final String name;
  final String address;
  final String contact;
  final String description;
  final int numberOfCourts;
  final String verificationStatus;
  final List<VenueImageModel> images;
  final List<VenueCourt> courts;

  VenueModel({
    required this.id,
    required this.name,
    required this.address,
    required this.contact,
    required this.description,
    required this.numberOfCourts,
    required this.verificationStatus,
    required this.images,
    required this.courts,
  });

  String? get primaryImageUrl {
    final primary = images.where((img) => img.isPrimary).firstOrNull;
    return primary?.url ?? (images.isNotEmpty ? images.first.url : null);
  }

  factory VenueModel.fromJson(Map<String, dynamic> json) {
    List<VenueImageModel> imagesList = [];
    if (json['images'] != null) {
      imagesList = (json['images'] as List)
          .map((img) => VenueImageModel.fromJson(img))
          .toList();
    }

    List<VenueCourt> courtsList = [];
    if (json['courts'] != null) {
      courtsList = (json['courts'] as List)
          .map((court) => VenueCourt.fromJson(court))
          .toList();
    }

    return VenueModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      contact: json['contact'] ?? '',
      description: json['description'] ?? '',
      numberOfCourts: json['number_of_courts'] ?? 0,
      verificationStatus: json['verification_status'] ?? 'pending',
      images: imagesList,
      courts: courtsList,
    );
  }
}
