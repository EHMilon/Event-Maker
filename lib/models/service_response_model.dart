import 'service_model.dart';

/// Data wrapper for service payloads returned by backend or mocked sources.
/// Keeps metadata handy for pagination, caching or diagnostic needs.
class ServiceResponse {
  final List<ServiceModel> services;
  final int totalCount;
  final bool fromCache;
  final Map<String, dynamic>? metadata;

  const ServiceResponse({
    required this.services,
    this.totalCount = 0,
    this.fromCache = false,
    this.metadata,
  });

  /// Factory helper that mirrors the current mock data shape while keeping
  /// the API contract stable for future backend integration.
  factory ServiceResponse.mock(
    List<ServiceModel> services, {
    Map<String, dynamic>? extraMetadata,
  }) {
    return ServiceResponse(
      services: services,
      totalCount: services.length,
      fromCache: true,
      metadata: {
        'source': 'mock',
        'generatedAt': DateTime.now().toIso8601String(),
        if (extraMetadata != null) ...extraMetadata,
      },
    );
  }
}
