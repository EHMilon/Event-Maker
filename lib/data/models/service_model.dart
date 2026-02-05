import 'review_model.dart';

enum ServiceType {
  event,
  photography,
  training,
  catering,
  cleaning,
  music,
  filming,
}

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
  });
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
