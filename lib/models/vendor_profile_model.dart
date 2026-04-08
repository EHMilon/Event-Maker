import 'package:event_maker/models/service_model.dart';
import 'package:event_maker/models/review_model.dart';

/// Represents vendor profile service from API response
class VendorServiceModel {
  final int id;
  final String title;
  final String coverImage;
  final String startingPrice;
  final String currency;
  final String? firstAddress;

  VendorServiceModel({
    required this.id,
    required this.title,
    required this.coverImage,
    required this.startingPrice,
    required this.currency,
    this.firstAddress,
  });

  factory VendorServiceModel.fromJson(Map<String, dynamic> json) {
    return VendorServiceModel(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      coverImage: json['cover_image'] as String? ?? '',
      startingPrice: json['starting_price'] as String? ?? '0.00',
      currency: json['currency'] as String? ?? 'AED',
      firstAddress: json['first_address'] as String?,
    );
  }
}

/// Represents vendor review from API response
class VendorReviewModel {
  final int id;
  final String customerName;
  final int rating;
  final String comment;
  final String createdAt;

  VendorReviewModel({
    required this.id,
    required this.customerName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory VendorReviewModel.fromJson(Map<String, dynamic> json) {
    return VendorReviewModel(
      id: json['id'] as int? ?? 0,
      customerName: json['customer_name'] as String? ?? '',
      rating: json['rating'] as int? ?? 0,
      comment: json['comment'] as String? ?? '',
      createdAt: json['created_at'] as String? ?? '',
    );
  }
}

/// Represents the aggregated profile information returned by the backend,
/// including services, reviews, and metadata.
class VendorProfileModel {
  final int id;
  final String name;
  final String avatar;
  final String? companyName;
  final String? bio;
  final String ratingAvg;
  final int totalReviews;
  final bool isAvailable;
  final List<VendorServiceModel> services;
  final List<VendorReviewModel> reviews;

  // Legacy fields for backward compatibility
  final ServiceProvider? provider;
  final String? bannerUrl;
  final List<String>? certifications;
  final double rating;
  final List<ServiceModel> serviceModels;
  final List<ReviewModel> reviewModels;

  VendorProfileModel({
    required this.id,
    required this.name,
    required this.avatar,
    this.companyName,
    this.bio,
    required this.ratingAvg,
    required this.totalReviews,
    required this.isAvailable,
    required this.services,
    required this.reviews,
    // Legacy fields
    this.provider,
    this.bannerUrl,
    this.certifications,
    this.rating = 0,
    this.serviceModels = const [],
    this.reviewModels = const [],
  });

  /// Factory constructor from API response
  factory VendorProfileModel.fromJson(Map<String, dynamic> json) {
    final servicesList =
        (json['services'] as List<dynamic>?)
            ?.map((e) => VendorServiceModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    final reviewsList =
        (json['reviews'] as List<dynamic>?)
            ?.map((e) => VendorReviewModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    // Convert to legacy format for backward compatibility
    final serviceModels = servicesList
        .map(
          (s) => ServiceModel(
            id: s.id.toString(),
            apiId: s.id,
            title: s.title,
            description: '', // API doesn't provide description
            coverImage: s.coverImage,
            currency: s.currency,
            basePrice: double.tryParse(s.startingPrice),
            images: [s.coverImage],
          ),
        )
        .toList();

    final reviewModels = reviewsList
        .map(
          (r) => ReviewModel(
            userName: r.customerName,
            userImageUrl: '',
            date: r.createdAt,
            rating: r.rating.toDouble(),
            reviewText: r.comment,
          ),
        )
        .toList();

    final ratingValue =
        double.tryParse(json['rating_avg'] as String? ?? '0') ?? 0;

    return VendorProfileModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      avatar: json['avatar'] as String? ?? '',
      companyName: json['company_name'] as String?,
      bio: json['bio'] as String?,
      ratingAvg: json['rating_avg'] as String? ?? '0.00',
      totalReviews: json['total_reviews'] as int? ?? 0,
      isAvailable: json['is_available'] as bool? ?? true,
      services: servicesList,
      reviews: reviewsList,
      // Legacy fields
      provider: ServiceProvider(
        name: json['name'] as String? ?? '',
        role: '',
        imageUrl: (json['avatar'] as String?) ?? '',
      ),
      rating: ratingValue,
      serviceModels: serviceModels,
      reviewModels: reviewModels,
    );
  }
}
