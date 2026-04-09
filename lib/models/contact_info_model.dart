/// Model for contact information settings from API
/// 
/// Backend Contract:
/// - GET /settings/contact-info
/// ```json
/// {
///   "success": true,
///   "message": "Contact setting retrieved successfully.",
///   "data": {
///     "id": 1,
///     "support_phone": "12321312",
///     "support_email": "",
///     "social_media": {
///       "instagram": "http://localhost:5173/settings",
///       "twitter": "http://localhost:5173/settings",
///       "facebook": "http://localhost:5173/settings"
///     },
///     "is_active": true,
///     "created_at": "2026-04-06T06:53:20.907600Z",
///     "updated_at": "2026-04-08T08:56:47.075135Z"
///   }
/// }
/// ```
class ContactInfoModel {
  final int id;
  final String supportPhone;
  final String supportEmail;
  final SocialMedia socialMedia;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ContactInfoModel({
    required this.id,
    required this.supportPhone,
    required this.supportEmail,
    required this.socialMedia,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ContactInfoModel.fromJson(Map<String, dynamic> json) {
    return ContactInfoModel(
      id: json['id'] as int? ?? 0,
      supportPhone: json['support_phone'] as String? ?? '',
      supportEmail: json['support_email'] as String? ?? '',
      socialMedia: SocialMedia.fromJson(json['social_media'] as Map<String, dynamic>? ?? {}),
      isActive: json['is_active'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'support_phone': supportPhone,
      'support_email': supportEmail,
      'social_media': socialMedia.toJson(),
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create a copy with optional field updates
  ContactInfoModel copyWith({
    int? id,
    String? supportPhone,
    String? supportEmail,
    SocialMedia? socialMedia,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ContactInfoModel(
      id: id ?? this.id,
      supportPhone: supportPhone ?? this.supportPhone,
      supportEmail: supportEmail ?? this.supportEmail,
      socialMedia: socialMedia ?? this.socialMedia,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Social media links model
class SocialMedia {
  final String instagram;
  final String twitter;
  final String facebook;

  const SocialMedia({
    required this.instagram,
    required this.twitter,
    required this.facebook,
  });

  factory SocialMedia.fromJson(Map<String, dynamic> json) {
    return SocialMedia(
      instagram: json['instagram'] as String? ?? '',
      twitter: json['twitter'] as String? ?? '',
      facebook: json['facebook'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'instagram': instagram,
      'twitter': twitter,
      'facebook': facebook,
    };
  }

  /// Create a copy with optional field updates
  SocialMedia copyWith({
    String? instagram,
    String? twitter,
    String? facebook,
  }) {
    return SocialMedia(
      instagram: instagram ?? this.instagram,
      twitter: twitter ?? this.twitter,
      facebook: facebook ?? this.facebook,
    );
  }
}

/// API Response wrapper for contact info
class ContactInfoResponse {
  final bool success;
  final String message;
  final ContactInfoModel? data;

  const ContactInfoResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory ContactInfoResponse.fromJson(Map<String, dynamic> json) {
    return ContactInfoResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: json['data'] != null 
          ? ContactInfoModel.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}
