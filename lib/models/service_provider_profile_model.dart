import 'package:event_maker/constants/api_constant.dart';

/// Certificate model for service provider profile
class ProviderCertificate {
  final int id;
  final String title;
  final String institute;
  final String issueDate;
  final String? file;

  const ProviderCertificate({
    required this.id,
    required this.title,
    required this.institute,
    required this.issueDate,
    this.file,
  });

  factory ProviderCertificate.fromJson(Map<String, dynamic> json) {
    return ProviderCertificate(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      institute: json['institute'] as String? ?? '',
      issueDate: json['issue_date'] as String? ?? '',
      file: json['file'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'institute': institute,
      'issue_date': issueDate,
      'file': file,
    };
  }

  /// Get full URL for certificate file
  String? get fullFileUrl => file != null ? ApiConstant.getFullMediaUrl(file) : null;
}

/// Approved service model for service provider profile (simplified version)
class ProviderApprovedService {
  final int id;
  final String title;
  final String serviceTypeName;
  final String roleName;
  final String? serviceAsName;
  final String? coverImage;
  final String currency;
  final String startingPrice;
  final String averageRating;
  final int totalReviews;
  final String createdAt;
  final String? firstAddress;

  const ProviderApprovedService({
    required this.id,
    required this.title,
    required this.serviceTypeName,
    required this.roleName,
    this.serviceAsName,
    this.coverImage,
    required this.currency,
    required this.startingPrice,
    required this.averageRating,
    required this.totalReviews,
    required this.createdAt,
    this.firstAddress,
  });

  factory ProviderApprovedService.fromJson(Map<String, dynamic> json) {
    return ProviderApprovedService(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      serviceTypeName: json['service_type_name'] as String? ?? '',
      roleName: json['role_name'] as String? ?? '',
      serviceAsName: json['service_as_name'] as String?,
      coverImage: json['cover_image'] as String?,
      currency: json['currency'] as String? ?? 'AED',
      startingPrice: json['starting_price'] as String? ?? '0.00',
      averageRating: json['average_rating'] as String? ?? '0.00',
      totalReviews: json['total_reviews'] as int? ?? 0,
      createdAt: json['created_at'] as String? ?? '',
      firstAddress: json['first_address'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'service_type_name': serviceTypeName,
      'role_name': roleName,
      'service_as_name': serviceAsName,
      'cover_image': coverImage,
      'currency': currency,
      'starting_price': startingPrice,
      'average_rating': averageRating,
      'total_reviews': totalReviews,
      'created_at': createdAt,
      'first_address': firstAddress,
    };
  }

  /// Get full URL for cover image
  String? get fullCoverImageUrl =>
      coverImage != null ? ApiConstant.getFullMediaUrl(coverImage) : null;

  /// Get rating as double
  double get ratingValue => double.tryParse(averageRating) ?? 0.0;

  /// Get starting price as double
  double get priceValue => double.tryParse(startingPrice) ?? 0.0;
}

/// Service provider profile model for "about" section API response
class ServiceProviderProfileModel {
  final int id;
  final String name;
  final String? avatar;
  final String? companyName;
  final String bio;
  final String averageRating;
  final int totalReviews;
  final List<ProviderCertificate> certificates;
  final List<ProviderApprovedService> approvedServices;

  const ServiceProviderProfileModel({
    required this.id,
    required this.name,
    this.avatar,
    this.companyName,
    required this.bio,
    required this.averageRating,
    required this.totalReviews,
    required this.certificates,
    required this.approvedServices,
  });

  /// Factory constructor from API response
  factory ServiceProviderProfileModel.fromJson(Map<String, dynamic> json) {
    return ServiceProviderProfileModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      avatar: json['avatar'] as String?,
      companyName: json['company_name'] as String?,
      bio: json['bio'] as String? ?? '',
      averageRating: json['average_rating'] as String? ?? '0.00',
      totalReviews: json['total_reviews'] as int? ?? 0,
      certificates: (json['certificates'] as List<dynamic>?)
              ?.map((e) => ProviderCertificate.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      approvedServices: (json['approved_services'] as List<dynamic>?)
              ?.map((e) => ProviderApprovedService.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatar': avatar,
      'company_name': companyName,
      'bio': bio,
      'average_rating': averageRating,
      'total_reviews': totalReviews,
      'certificates': certificates.map((c) => c.toJson()).toList(),
      'approved_services': approvedServices.map((s) => s.toJson()).toList(),
    };
  }

  /// Get full URL for avatar
  String? get fullAvatarUrl =>
      avatar != null ? ApiConstant.getFullMediaUrl(avatar) : null;

  /// Get rating as double
  double get ratingValue => double.tryParse(averageRating) ?? 0.0;

  /// Check if provider has certificates
  bool get hasCertificates => certificates.isNotEmpty;

  /// Check if provider has approved services
  bool get hasServices => approvedServices.isNotEmpty;
}

/// API Response wrapper for service provider profile
class ServiceProviderProfileResponse {
  final bool success;
  final String message;
  final String section;
  final ServiceProviderProfileModel data;

  const ServiceProviderProfileResponse({
    required this.success,
    required this.message,
    required this.section,
    required this.data,
  });

  factory ServiceProviderProfileResponse.fromJson(Map<String, dynamic> json) {
    return ServiceProviderProfileResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      section: json['section'] as String? ?? '',
      data: ServiceProviderProfileModel.fromJson(
          json['data'] as Map<String, dynamic>? ?? {}),
    );
  }
}
