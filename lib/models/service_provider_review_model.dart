import 'package:event_maker/constants/api_constant.dart';

/// Customer model for service provider review
class ReviewCustomer {
  final int id;
  final String name;
  final String? avatar;

  const ReviewCustomer({
    required this.id,
    required this.name,
    this.avatar,
  });

  factory ReviewCustomer.fromJson(Map<String, dynamic> json) {
    return ReviewCustomer(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      avatar: json['avatar'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatar': avatar,
    };
  }

  /// Get full URL for avatar
  String? get fullAvatarUrl =>
      avatar != null ? ApiConstant.getFullMediaUrl(avatar) : null;
}

/// Service provider review model for "reviews" section API response
class ServiceProviderReview {
  final int id;
  final int serviceId;
  final String serviceTitle;
  final ReviewCustomer customer;
  final int rating;
  final String comment;
  final String createdAt;

  const ServiceProviderReview({
    required this.id,
    required this.serviceId,
    required this.serviceTitle,
    required this.customer,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory ServiceProviderReview.fromJson(Map<String, dynamic> json) {
    return ServiceProviderReview(
      id: json['id'] as int? ?? 0,
      serviceId: json['service_id'] as int? ?? 0,
      serviceTitle: json['service_title'] as String? ?? '',
      customer: ReviewCustomer.fromJson(
          json['customer'] as Map<String, dynamic>? ?? {}),
      rating: json['rating'] as int? ?? 0,
      comment: json['comment'] as String? ?? '',
      createdAt: json['created_at'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'service_id': serviceId,
      'service_title': serviceTitle,
      'customer': customer.toJson(),
      'rating': rating,
      'comment': comment,
      'created_at': createdAt,
    };
  }

  /// Get rating as double for display
  double get ratingValue => rating.toDouble();
}

/// Provider info for reviews section (subset of profile)
class ProviderReviewInfo {
  final int id;
  final String name;
  final String? avatar;
  final String? companyName;
  final String bio;
  final String averageRating;
  final int totalReviews;

  const ProviderReviewInfo({
    required this.id,
    required this.name,
    this.avatar,
    this.companyName,
    required this.bio,
    required this.averageRating,
    required this.totalReviews,
  });

  factory ProviderReviewInfo.fromJson(Map<String, dynamic> json) {
    return ProviderReviewInfo(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      avatar: json['avatar'] as String?,
      companyName: json['company_name'] as String?,
      bio: json['bio'] as String? ?? '',
      averageRating: json['average_rating'] as String? ?? '0.00',
      totalReviews: json['total_reviews'] as int? ?? 0,
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
    };
  }

  /// Get full URL for avatar
  String? get fullAvatarUrl =>
      avatar != null ? ApiConstant.getFullMediaUrl(avatar) : null;

  /// Get rating as double
  double get ratingValue => double.tryParse(averageRating) ?? 0.0;
}

/// API Response wrapper for service provider reviews
class ServiceProviderReviewsResponse {
  final bool success;
  final String message;
  final String section;
  final ProviderReviewInfo provider;
  final List<ServiceProviderReview> data;

  const ServiceProviderReviewsResponse({
    required this.success,
    required this.message,
    required this.section,
    required this.provider,
    required this.data,
  });

  factory ServiceProviderReviewsResponse.fromJson(Map<String, dynamic> json) {
    return ServiceProviderReviewsResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      section: json['section'] as String? ?? '',
      provider: ProviderReviewInfo.fromJson(
          json['provider'] as Map<String, dynamic>? ?? {}),
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => ServiceProviderReview.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
