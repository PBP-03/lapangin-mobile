class User {
  final String id;
  final String username;
  final String email;
  final String? firstName;
  final String? lastName;
  final String role; // 'user', 'mitra', 'admin'
  final String? phoneNumber;
  final String? address;
  final String? profilePicture;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.firstName,
    this.lastName,
    required this.role,
    this.phoneNumber,
    this.address,
    this.profilePicture,
    this.isVerified = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String? ?? '',
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      role: json['role'] as String,
      phoneNumber: json['phone_number'] as String?,
      address: json['address'] as String?,
      profilePicture: json['profile_picture'] as String?,
      isVerified: json['is_verified'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'role': role,
      'phone_number': phoneNumber,
      'address': address,
      'profile_picture': profilePicture,
      'is_verified': isVerified,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get fullName {
    final first = firstName ?? '';
    final last = lastName ?? '';
    return '$first $last'.trim().isEmpty ? username : '$first $last'.trim();
  }

  bool get isUser => role == 'user';
  bool get isMitra => role == 'mitra';
  bool get isAdmin => role == 'admin';
}
