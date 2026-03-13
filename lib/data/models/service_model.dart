import 'review_model.dart';

enum ServiceType { event, photography, training, catering, cleaning, filming }

class ServiceModel {
  final String id;
  final String title;
  final String description;
  final List<String> images;
  final ServiceType type;
  final ServiceProvider provider;
  final String location;
  final double? rating;
  final int? reviewCount;
  final DateTime? date;
  final double? basePrice;
  final String priceUnit;
  final List<ServicePackage>? packages;
  final bool isBookmarked;

  ServiceModel({
    required this.id,
    required this.title,
    required this.description,
    required this.images,
    required this.type,
    required this.provider,
    required this.location,
    this.rating,
    this.reviewCount,
    this.date,
    this.basePrice,
    this.priceUnit = 'AED',
    this.packages,
    this.isBookmarked = false,
  });

  ServiceModel copyWith({
    String? id,
    String? title,
    String? description,
    List<String>? images,
    ServiceType? type,
    ServiceProvider? provider,
    String? location,
    double? rating,
    int? reviewCount,
    DateTime? date,
    double? basePrice,
    String? priceUnit,
    List<ServicePackage>? packages,
    bool? isBookmarked,
  }) {
    return ServiceModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      images: images ?? this.images,
      type: type ?? this.type,
      provider: provider ?? this.provider,
      location: location ?? this.location,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      date: date ?? this.date,
      basePrice: basePrice ?? this.basePrice,
      priceUnit: priceUnit ?? this.priceUnit,
      packages: packages ?? this.packages,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }
}

class ServiceProvider {
  final String name;
  final String role;
  final String imageUrl;
  final String? bannerUrl;
  final bool isVerified;
  final List<String>? certifications;
  final String? bio;
  final List<ServiceModel>? services;
  final List<ReviewModel>? reviews;

  ServiceProvider({
    required this.name,
    required this.role,
    required this.imageUrl,
    this.bannerUrl,
    this.isVerified = false,
    this.certifications,
    this.bio,
    this.services,
    this.reviews,
  });
}

class ServicePackage {
  final String name;
  final double price;
  final List<String> features;

  ServicePackage({
    required this.name,
    required this.price,
    required this.features,
  });
}
