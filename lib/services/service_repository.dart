import '../mock_data/mock_data.dart';
import '../mock_data/review_mock.dart';
import '../models/service_model.dart';
import '../models/service_response_model.dart';
import '../models/vendor_profile_model.dart';

/// Repository abstraction for fetching services data.
/// Currently returns mock data but keeps the contract identical to what a backend
/// service would provide.
class ServiceRepository {
  const ServiceRepository();

  /// Simulated category -> [ServiceType] map. Backend can extend this if needed.
  static const Map<String, ServiceType> _categoryLookup = {
    'catering': ServiceType.catering,
    'filming': ServiceType.filming,
    'cleaning': ServiceType.cleaning,
    'photography': ServiceType.photography,
    'event': ServiceType.event,
    'training': ServiceType.training,
  };

  ServiceType? _typeFromCategory(String category) {
    return _categoryLookup[category.toLowerCase()];
  }

  /// Fetches services either for a provider dashboard or filtered views.
  ///
  /// TODO: Replace the mock delay and data with a real API call and handle
  /// network errors/pagination, caching, etc.
  Future<ServiceResponse> fetchServices({
    ServiceType? filterType,
    String? category,
  }) async {
    await Future.delayed(const Duration(milliseconds: 350));
    final resolvedType =
        filterType ?? (category != null ? _typeFromCategory(category) : null);
    final rawData = resolvedType == null
        ? MockData.homeServices
        : MockData.getServicesByType(resolvedType);
    final data = rawData
        .map(
          (service) => service.date != null
              ? service
              : service.copyWith(date: DateTime.now()),
        )
        .toList();

    return ServiceResponse.mock(
      data,
      extraMetadata: {
        'requestedType': resolvedType?.name ?? 'all',
        'category': category ?? resolvedType?.name ?? 'all',
      },
    );
  }

  /// Simple helper for fetching a single service. Backend can implement server
  /// queries with identical signature.
  Future<ServiceModel?> fetchServiceById(String id) async {
    final response = await fetchServices();
    try {
      return response.services.firstWhere((service) => service.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<VendorProfileModel> fetchVendorProfile(
    ServiceProvider provider,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final providerServices = MockData.homeServices
        .where((service) => service.provider.name == provider.name)
        .toList();
    final reviews = ReviewMock.getReviewsForProvider(provider.name);
    final rating = providerServices.isEmpty
        ? 0.0
        : providerServices.map((s) => s.rating ?? 0).reduce((a, b) => a + b) /
              providerServices.length;

    return VendorProfileModel(
      provider: provider,
      name: provider.name,
      bannerUrl:
          'https://images.unsplash.com/photo-1540039155733-5bb30b53aa14?q=80&w=1000&auto=format&fit=crop',
      certifications: ['Professional Chef', 'Pizza Artisan'],
      bio:
          'Amazing service! The team made our wedding day stress-free and truly magical. Everything was perfectly organized from the décor to the timeline. Highly recommend them.',
      rating: rating,
      reviewCount: reviews.length,
      services: providerServices,
      reviews: reviews,
    );
  }
}
