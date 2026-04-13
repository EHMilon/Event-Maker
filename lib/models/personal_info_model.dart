import 'package:event_maker/constants/api_constant.dart';

/// Personal info model for user profile settings
class PersonalInfoModel {
  final String id;
  final String fullName;
  final String email;
  final String? avatar;
  final String role;
  final String? nationality;
  final String? phoneNumber;
  final String? bio;
  final bool isAvailable;
  final String? availableBalance; // Only for providers

  const PersonalInfoModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.avatar,
    required this.role,
    this.nationality,
    this.phoneNumber,
    this.bio,
    this.isAvailable = true,
    this.availableBalance,
  });

  factory PersonalInfoModel.fromJson(Map<String, dynamic> json) {
    return PersonalInfoModel(
      id: json['id'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      avatar: json['avatar'] as String?,
      role: json['role'] as String? ?? 'customer',
      nationality: json['nationality'] as String?,
      phoneNumber: json['phone_number'] as String?,
      bio: json['bio'] as String?,
      isAvailable: json['is_available'] as bool? ?? true,
      availableBalance: json['available_balance'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'avatar': avatar,
      'role': role,
      'nationality': nationality,
      'phone_number': phoneNumber,
      'bio': bio,
      'is_available': isAvailable,
    };
  }

  /// Get full URL for avatar
  String? get fullAvatarUrl =>
      avatar != null ? ApiConstant.getFullMediaUrl(avatar) : null;

  /// Check if user is a provider
  bool get isProvider => role == 'provider';

  /// Create a copy with optional field updates
  PersonalInfoModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? avatar,
    String? role,
    String? nationality,
    String? phoneNumber,
    String? bio,
    bool? isAvailable,
    String? availableBalance,
  }) {
    return PersonalInfoModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      role: role ?? this.role,
      nationality: nationality ?? this.nationality,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      bio: bio ?? this.bio,
      isAvailable: isAvailable ?? this.isAvailable,
      availableBalance: availableBalance ?? this.availableBalance,
    );
  }
}

/// API Response wrapper for personal info
class PersonalInfoResponse {
  final bool success;
  final String message;
  final PersonalInfoModel data;

  const PersonalInfoResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory PersonalInfoResponse.fromJson(Map<String, dynamic> json) {
    return PersonalInfoResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: PersonalInfoModel.fromJson(
        json['data'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}
