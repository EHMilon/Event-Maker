/// User model representing authenticated user data.
///
/// Backend Contract:
/// - id: Unique user identifier (UUID or integer)
/// - name: Full name of the user
/// - email: User's email address
/// - phone: User's phone number with country code
/// - userType: 'customer' or 'provider'
/// - nationality: User's nationality (optional)
/// - isVerified: Whether email is verified
/// - avatar: User's profile picture URL (optional)
class UserModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String userType;
  final String? nationality;
  final bool isVerified;
  final String? avatar;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.userType,
    this.nationality,
    this.isVerified = false,
    this.avatar,
  });

  /// Check if user is a service provider
  bool get isServiceProvider => userType == 'provider';

  /// Check if user is a customer
  bool get isCustomer => userType == 'customer';

  /// Create UserModel from API response JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? json['full_name'] ?? json['fullName'] ?? '',
      email: json['email'] ?? json['email_address'] ?? json['emailAddress'] ?? '',
      phone: json['phone'] ?? json['phone_number'] ?? json['phoneNumber'],
      userType: json['user_type'] ?? json['userType'] ?? json['role'] ?? 'customer',
      nationality: json['nationality'],
      isVerified: json['is_verified'] ?? json['isVerified'] ?? false,
      avatar: json['avatar'],
    );
  }

  /// Convert UserModel to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'user_type': userType,
      'nationality': nationality,
      'is_verified': isVerified,
    };
  }

  /// Create a copy with updated fields
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? userType,
    String? nationality,
    bool? isVerified,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      userType: userType ?? this.userType,
      nationality: nationality ?? this.nationality,
      isVerified: isVerified ?? this.isVerified,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, email: $email, userType: $userType)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
