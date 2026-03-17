import 'package:event_maker/models/service_model.dart';
import 'package:event_maker/models/review_model.dart';

/// Represents the aggregated profile information returned by the backend,
/// including services, reviews, and metadata.
class VendorProfileModel {
  final ServiceProvider provider;
  final String name;
  final String? bannerUrl;
  final List<String>? certifications;
  final String? bio;
  final double rating;
  final int reviewCount;
  final List<ServiceModel> services;
  final List<ReviewModel> reviews;

  VendorProfileModel({
    required this.provider,
    required this.name,
    this.bannerUrl,
    this.certifications,
    this.bio,
    required this.rating,
    required this.reviewCount,
    required this.services,
    required this.reviews,
  });
}
