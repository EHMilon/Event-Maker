import 'dart:convert';
import 'dart:io';
import '../mock_data/mock_data.dart';
import '../utils/user_preferences.dart';
import '../utils/logger.dart';
import '../mock_data/review_mock.dart';
import '../models/service_model.dart';
import '../models/my_service_model.dart';
import '../models/service_request_model.dart';
import '../models/service_response_model.dart';
import '../models/vendor_profile_model.dart';
import 'api_service.dart';
import 'api_exception.dart';
import '../constants/api_constant.dart';

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

  /// Fetch vendor profile by provider ID from API
  /// Uses: GET /providers/vendor-info/{id}
  Future<VendorProfileModel> fetchVendorProfileById(int providerId) async {
    final api = ApiService();

    try {
      final response = await api.get(ApiConstant.vendorProfile(providerId));
      Log.d('=======> fetchVendorProfileById - Response: $response');
      
      // Handle nested response structure
      final data = response is Map ? (response['data'] ?? response) : response;
      return VendorProfileModel.fromJson(data as Map<String, dynamic>);
    } on ApiException catch (e) {
      Log.e('=======> fetchVendorProfileById - ApiException: ${e.message}');
      throw ApiException(message: e.message);
    } catch (e) {
      Log.e('=======> fetchVendorProfileById - Error: $e');
      throw ApiException(message: 'Failed to fetch vendor profile: $e');
    }
  }

  /// Fetch vendor profile by provider ID (alias for backward compatibility)
  Future<VendorProfileModel> fetchVendorProfile(
    ServiceProvider provider, {
    int? providerId,
  }) async {
    // If providerId is provided, use API
    if (providerId != null) {
      return fetchVendorProfileById(providerId);
    }
    
    // Fallback to mock data for backward compatibility
    await Future.delayed(const Duration(milliseconds: 300));
    final providerServices = MockData.homeServices
        .where((service) => service.provider.name == provider.name)
        .toList();
    final reviews = ReviewMock.getReviewsForProvider(provider.name);
    final rating = providerServices.isEmpty
        ? 0.0
        : providerServices.map((s) => s.rating ?? 0).reduce((a, b) => a + b) /
              providerServices.length;

    // Return mock data using legacy format
    return VendorProfileModel(
      id: 0,
      name: provider.name,
      avatar: provider.imageUrl ?? '',
      ratingAvg: rating.toStringAsFixed(2),
      totalReviews: reviews.length,
      isAvailable: true,
      services: const [],
      reviews: const [],
      provider: provider,
      bannerUrl:
          'https://images.unsplash.com/photo-1540039155733-5bb30b53aa14?q=80&w=1000&auto=format&fit=crop',
      certifications: ['Professional Chef', 'Pizza Artisan'],
      bio:
          'Amazing service! The team made our wedding day stress-free and truly magical. Everything was perfectly organized from the décor to the timeline. Highly recommend them.',
      rating: rating,
      serviceModels: providerServices,
      reviewModels: reviews,
    );
  }

  /// Create a new service via API
  Future<ServiceModel> createService(ServiceRequestModel request) async {
    final api = ApiService();

    // Check authentication before making API call
    final token = await UserPreferences.getAccessToken();
    Log.d(
      '=======> createService - Token check: ${token != null ? "EXISTS (${token.length} chars)" : "NULL"}',
    );

    if (token == null || token.isEmpty) {
      throw ApiException(
        message: 'Authentication required. Please log in again.',
      );
    }

    try {
      // Check if we have a cover image to upload
      if (request.coverImage != null && request.coverImage!.isNotEmpty) {
        // Use multipart request for image upload
        final response = await api.multipart(
          'POST',
          ApiConstant.services,
          fields: request.toMultipartFields(),
          files: {'cover_image': File(request.coverImage!)},
        );
        return ServiceModel.fromJson(response['data']);
      } else {
        // Use regular POST request without image
        final response = await api.post(
          ApiConstant.services,
          body: request.toJson(),
        );
        return ServiceModel.fromJson(response['data']);
      }
    } on ApiException catch (e) {
      throw ApiException(message: e.message);
    } catch (e) {
      throw ApiException(message: 'Failed to create service: $e');
    }
  }

  /// Update an existing service via API using PATCH with multipart/form-data
  /// Backend expects PATCH method for update endpoint
  Future<ServiceModel> updateService(ServiceRequestModel request) async {
    final api = ApiService();

    if (request.id == null) {
      throw ApiException(message: 'Service ID is required for update');
    }

    // Check authentication before making API call
    final token = await UserPreferences.getAccessToken();
    Log.d(
      '=======> updateService - Token check: ${token != null ? "EXISTS (${token.length} chars)" : "NULL"}',
    );

    if (token == null || token.isEmpty) {
      throw ApiException(
        message: 'Authentication required. Please log in again.',
      );
    }

    try {
      // Check if cover image is a new local file (not an existing API path)
      final coverImage = request.coverImage;
      final isNewImage =
          coverImage != null &&
          coverImage.isNotEmpty &&
          !coverImage.startsWith('/media/') &&
          !coverImage.startsWith('http://') &&
          !coverImage.startsWith('https://');

      Log.d(
        '=======> updateService - ID: ${request.id}, isNewImage: $isNewImage',
      );
      Log.d('=======> updateService - coverImage: $coverImage');

      // Backend expects PATCH method with multipart/form-data for update
      Map<String, File> files = {};
      if (isNewImage) {
        files = {'cover_image': File(coverImage!)};
        Log.d('=======> updateService - Using multipart PATCH with new image');
      } else {
        Log.d('=======> updateService - Using multipart PATCH without image');
      }

      final response = await api.multipart(
        'PATCH',
        ApiConstant.serviceUpdate(request.id!),
        fields: request.toMultipartFields(),
        files: files,
      );

      // Handle response - might be wrapped in 'data' or direct object
      final data = response is Map ? (response['data'] ?? response) : response;
      Log.d('=======> updateService - Response data: $data');
      return ServiceModel.fromJson(data);
    } on ApiException catch (e) {
      Log.e('=======> updateService - ApiException: ${e.message}');
      throw ApiException(message: e.message);
    } catch (e) {
      Log.e('=======> updateService - Error: $e');
      throw ApiException(message: 'Failed to update service: $e');
    }
  }

  /// Fetch service provider's own services (My Services)
  /// Uses: api/services endpoint with lightweight MyServiceModel
  Future<MyServiceListResponse> fetchMyServices() async {
    final api = ApiService();

    try {
      final response = await api.get(ApiConstant.services);
      return MyServiceListResponse.fromJson(response);
    } on ApiException catch (e) {
      throw ApiException(message: e.message);
    } catch (e) {
      throw ApiException(message: 'Failed to fetch services: $e');
    }
  }

  /// Fetch a single service detail by ID
  /// Uses: api/services/detail/{id} endpoint
  Future<ServiceModel> fetchServiceDetail(int serviceId) async {
    final api = ApiService();

    try {
      final response = await api.get(ApiConstant.serviceDetail(serviceId));
      return ServiceModel.fromJson(response['data']);
    } on ApiException catch (e) {
      throw ApiException(message: e.message);
    } catch (e) {
      throw ApiException(message: 'Failed to fetch service detail: $e');
    }
  }
}
