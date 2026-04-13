import 'dart:io';
import '../mock_data/mock_data.dart';
import '../services/storage_service.dart';
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
      id: 'mock_${provider.name.hashCode}',
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
    final token = await StorageService().getAccessToken();
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
    } on ApiException {
          rethrow;
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
    final token = await StorageService().getAccessToken();
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
        files = {'cover_image': File(coverImage)};
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
          rethrow;
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

  /// Fetch customer services grouped by service_as_name
  /// Uses: GET api/services/customer-services?service_type_name=Event
  /// Query params: service_type_name (required), service_as_name (optional for filtering)
  Future<CustomerServicesResponse> fetchCustomerServices({
    required String serviceTypeName,
    String? serviceAsName,
  }) async {
    final api = ApiService();

    try {
      // Build query parameters
      final queryParams = <String, String>{
        'service_type_name': serviceTypeName,
      };
      if (serviceAsName != null && serviceAsName.isNotEmpty) {
        queryParams['service_as_name'] = serviceAsName;
      }

      final response = await api.get(
        ApiConstant.customerServices,
        queryParams: queryParams,
      );
      return CustomerServicesResponse.fromJson(response);
    } on ApiException catch (e) {
      throw ApiException(message: e.message);
    } catch (e) {
      throw ApiException(message: 'Failed to fetch customer services: $e');
    }
  }

  /// Fetch subcategories (unique service_as_name list) by service_type_name
  /// Uses: GET api/services/subcategories?service_type_name=Event
  Future<List<String>> fetchSubcategories(String serviceTypeName) async {
    final api = ApiService();

    try {
      final response = await api.get(
        ApiConstant.subcategories,
        queryParams: {'service_type_name': serviceTypeName},
      );
      return SubcategoriesResponse.fromJson(response).data;
    } on ApiException catch (e) {
      throw ApiException(message: e.message);
    } catch (e) {
      throw ApiException(message: 'Failed to fetch subcategories: $e');
    }
  }

  /// Fetch customer service detail by ID
  /// Uses: GET api/services/customer-services/{id}
  Future<ServiceModel> fetchCustomerServiceDetail(int serviceId) async {
    final api = ApiService();

    try {
      final response = await api.get(
        ApiConstant.customerServiceDetail(serviceId),
      );
      return ServiceModel.fromJson(response['data']);
    } on ApiException catch (e) {
      throw ApiException(message: e.message);
    } catch (e) {
      throw ApiException(
        message: 'Failed to fetch customer service detail: $e',
      );
    }
  }

  /// Toggle bookmark status for a service
  /// Uses: POST api/services/bookmark-toggle/{serviceId}
  /// Response: { "success": true, "message": "Service bookmark status updated successfully.", "data": { "service_id": 16, "is_bookmarked": false } }
  Future<BookmarkToggleResponse> toggleBookmark(int serviceId) async {
    final api = ApiService();

    try {
      final response = await api.post(ApiConstant.bookmarkToggle(serviceId));
      Log.d('=======> toggleBookmark - Response: $response');
      return BookmarkToggleResponse.fromJson(response);
    } on ApiException catch (e) {
      Log.e('=======> toggleBookmark - ApiException: ${e.message}');
      throw ApiException(message: e.message);
    } catch (e) {
      Log.e('=======> toggleBookmark - Error: $e');
      throw ApiException(message: 'Failed to toggle bookmark: $e');
    }
  }

  /// Get user's bookmarked services
  /// Uses: GET api/services/my-bookmarked?page=1&page_size=10
  Future<BookmarkedServicesResponse> getMyBookmarkedServices({
    int page = 1,
    int pageSize = 10,
  }) async {
    final api = ApiService();

    try {
      final response = await api.get(
        ApiConstant.myBookmarked,
        queryParams: {
          'page': page.toString(),
          'page_size': pageSize.toString(),
        },
      );
      Log.d('=======> getMyBookmarkedServices - Response: $response');
      return BookmarkedServicesResponse.fromJson(response);
    } on ApiException catch (e) {
      Log.e('=======> getMyBookmarkedServices - ApiException: ${e.message}');
      throw ApiException(message: e.message);
    } catch (e) {
      Log.e('=======> getMyBookmarkedServices - Error: $e');
      throw ApiException(message: 'Failed to fetch bookmarked services: $e');
    }
  }

  /// Search for services on Map
  /// Uses: GET api/services/search
  Future<Map<String, dynamic>> searchMapServices(Map<String, dynamic> params) async {
    final api = ApiService();
    try {
      final queryParams = <String, String>{};
      params.forEach((key, value) {
        if (value != null && value.toString().isNotEmpty) {
          queryParams[key] = value.toString();
        }
      });
      final response = await api.get(
        ApiConstant.serviceSearch,
        queryParams: queryParams,
      );
      return response as Map<String, dynamic>;
    } on ApiException catch (e) {
      throw ApiException(message: e.message);
    } catch (e) {
      throw ApiException(message: 'Failed to search map services: $e');
    }
  }

  /// Search customer services by query string
  /// Uses: GET /api/services/customer-services-search?search=decor
  /// Response: { "success": true, "message": "...", "data": { "total_count": 5, "services": [...] } }
  Future<CustomerServicesSearchResponse> searchCustomerServices(String query) async {
    final api = ApiService();

    try {
      final response = await api.get(
        ApiConstant.customerServicesSearch,
        queryParams: {'search': query},
      );
      return CustomerServicesSearchResponse.fromJson(response);
    } on ApiException catch (e) {
      throw ApiException(message: e.message);
    } catch (e) {
      throw ApiException(message: 'Failed to search services: $e');
    }
  }
}

/// Response model for customer services search
/// GET /services/customer-services-search?search=decor
/// Response: { "success": true, "message": "...", "search": "v", "total": 8, "data": [...] }
class CustomerServicesSearchResponse {
  final bool success;
  final String message;
  final int totalCount;
  final List<ServiceModel> services;

  CustomerServicesSearchResponse({
    required this.success,
    required this.message,
    required this.totalCount,
    required this.services,
  });

  factory CustomerServicesSearchResponse.fromJson(Map<String, dynamic> json) {
    // API returns: { "success": true, "message": "...", "total": 8, "data": [...] }
    // Note: data is a direct array, not nested under data.services
    final dataList = json['data'] as List<dynamic>? ?? [];
    
    return CustomerServicesSearchResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      totalCount: json['total'] as int? ?? 0,
      services: dataList
          .map((e) => ServiceModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Response model for customer services grouped by service_as_name
class CustomerServicesResponse {
  final bool success;
  final String message;
  final String serviceTypeName;
  final int groupPreviewLimit;
  final int totalGroups;
  final List<ServiceGroup> data;

  CustomerServicesResponse({
    required this.success,
    required this.message,
    required this.serviceTypeName,
    required this.groupPreviewLimit,
    required this.totalGroups,
    required this.data,
  });

  factory CustomerServicesResponse.fromJson(Map<String, dynamic> json) {
    return CustomerServicesResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      serviceTypeName: json['service_type_name'] as String? ?? '',
      groupPreviewLimit: json['group_preview_limit'] as int? ?? 5,
      totalGroups: json['total_groups'] as int? ?? 0,
      data:
          (json['data'] as List<dynamic>?)
              ?.map((e) => ServiceGroup.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  /// Get all services from all groups (flattened)
  List<ServiceModel> get allServices {
    return data.expand((group) => group.services).toList();
  }
}

/// Service group model (grouped by service_as_name)
class ServiceGroup {
  final String serviceAsName;
  final int totalServices;
  final int previewCount;
  final bool hasMore;
  final List<ServiceModel> services;

  ServiceGroup({
    required this.serviceAsName,
    required this.totalServices,
    required this.previewCount,
    required this.hasMore,
    required this.services,
  });

  factory ServiceGroup.fromJson(Map<String, dynamic> json) {
    return ServiceGroup(
      serviceAsName: json['service_as_name'] as String? ?? '',
      totalServices: json['total_services'] as int? ?? 0,
      previewCount: json['preview_count'] as int? ?? 0,
      hasMore: json['has_more'] as bool? ?? false,
      services:
          (json['services'] as List<dynamic>?)
              ?.map((e) => ServiceModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  ServiceGroup copyWith({
    String? serviceAsName,
    int? totalServices,
    int? previewCount,
    bool? hasMore,
    List<ServiceModel>? services,
  }) {
    return ServiceGroup(
      serviceAsName: serviceAsName ?? this.serviceAsName,
      totalServices: totalServices ?? this.totalServices,
      previewCount: previewCount ?? this.previewCount,
      hasMore: hasMore ?? this.hasMore,
      services: services ?? this.services,
    );
  }
}

/// Response model for subcategories
class SubcategoriesResponse {
  final bool success;
  final String message;
  final List<String> data;

  SubcategoriesResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory SubcategoriesResponse.fromJson(Map<String, dynamic> json) {
    return SubcategoriesResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data:
          (json['data'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          [],
    );
  }
}

/// Response model for bookmark toggle
/// Response: { "success": true, "message": "Service bookmark status updated successfully.", "data": { "service_id": 16, "is_bookmarked": false } }
class BookmarkToggleResponse {
  final bool success;
  final String message;
  final BookmarkData data;

  BookmarkToggleResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory BookmarkToggleResponse.fromJson(Map<String, dynamic> json) {
    return BookmarkToggleResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: BookmarkData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

/// Bookmark data containing service ID and bookmark status
class BookmarkData {
  final int serviceId;
  final bool isBookmarked;

  BookmarkData({required this.serviceId, required this.isBookmarked});

  factory BookmarkData.fromJson(Map<String, dynamic> json) {
    return BookmarkData(
      serviceId: json['service_id'] as int? ?? 0,
      isBookmarked: json['is_bookmarked'] as bool? ?? false,
    );
  }
}

/// Response model for user's bookmarked services
/// GET /services/my-bookmarked?page=1&page_size=10
class BookmarkedServicesResponse {
  final bool success;
  final String message;
  final BookmarkedPagination pagination;
  final List<ServiceModel> data;

  BookmarkedServicesResponse({
    required this.success,
    required this.message,
    required this.pagination,
    required this.data,
  });

  factory BookmarkedServicesResponse.fromJson(Map<String, dynamic> json) {
    return BookmarkedServicesResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      pagination: BookmarkedPagination.fromJson(
        json['pagination'] as Map<String, dynamic>? ?? {},
      ),
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => ServiceModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// Pagination info for bookmarked services
class BookmarkedPagination {
  final int currentPage;
  final int pageSize;
  final int totalPages;
  final int totalItems;

  BookmarkedPagination({
    required this.currentPage,
    required this.pageSize,
    required this.totalPages,
    required this.totalItems,
  });

  factory BookmarkedPagination.fromJson(Map<String, dynamic> json) {
    return BookmarkedPagination(
      currentPage: json['current_page'] as int? ?? 1,
      pageSize: json['page_size'] as int? ?? 10,
      totalPages: json['total_pages'] as int? ?? 1,
      totalItems: json['total_items'] as int? ?? 0,
    );
  }
}
