class Review {
  final String id;
  final String bookingId;
  final int rating;
  final String? comment;
  final DateTime createdAt;

  // Additional info for display
  final String? userName;
  final String? userProfilePicture;
  final String? venueName;

  Review({
    required this.id,
    required this.bookingId,
    required this.rating,
    this.comment,
    required this.createdAt,
    this.userName,
    this.userProfilePicture,
    this.venueName,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as String,
      bookingId: json['booking'] as String? ?? json['booking_id'] as String,
      rating: json['rating'] as int,
      comment: json['comment'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      userName: json['user_name'] as String?,
      userProfilePicture: json['user_profile_picture'] as String?,
      venueName: json['venue_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking': bookingId,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt.toIso8601String(),
      'user_name': userName,
      'user_profile_picture': userProfilePicture,
      'venue_name': venueName,
    };
  }
}
