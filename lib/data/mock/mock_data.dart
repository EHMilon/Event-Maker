import 'package:event_maker/data/models/service_model.dart';
import 'package:event_maker/data/models/review_model.dart';
import 'package:event_maker/data/mock/services_mock.dart';
import 'package:event_maker/data/mock/review_mock.dart';

/// Centralized mock data file
/// Acts as a facade to the specialized mock databases
/// 
/// For services data, use [ServicesMock] directly for more control
/// For reviews data, use [ReviewMock] directly for more control
class MockData {
  // =====================================================
  // DELEGATED METHODS - Forward to specialized mock classes
  // =====================================================

  /// Get all home services (delegated to ServicesMock)
  static List<ServiceModel> get homeServices => ServicesMock.allServices;

  /// Get bookmarked services (delegated to ServicesMock)
  static List<ServiceModel> get bookmarkedServices =>
      ServicesMock.bookmarkedServices;

  /// Get services by type (delegated to ServicesMock)
  static List<ServiceModel> getServicesByType(ServiceType type) =>
      ServicesMock.getServicesByType(type);

  /// Get services for home section (delegated to ServicesMock)
  static List<ServiceModel> getHomeSectionServices(String section) =>
      ServicesMock.getHomeSectionServices(section);

  /// Get all reviews (delegated to ReviewMock)
  static List<ReviewModel> get reviews => ReviewMock.reviews;

  // =====================================================
  // ASYNC API METHODS - For simulated network calls
  // =====================================================

  /// Fetch all services with simulated delay
  static Future<List<ServiceModel>> fetchAllServices({Duration? delay}) =>
      ServicesMock.fetchAllServices(delay: delay);

  /// Fetch services by category with simulated delay
  static Future<List<ServiceModel>> fetchServicesByCategory(
    String category, {
    Duration? delay,
  }) =>
      ServicesMock.fetchServicesByCategory(category, delay: delay);

  /// Fetch bookmarked services with simulated delay
  static Future<List<ServiceModel>> fetchBookmarkedServices({Duration? delay}) =>
      ServicesMock.fetchBookmarkedServices(delay: delay);

  /// Search services with simulated delay
  static Future<List<ServiceModel>> searchServices(
    String query, {
    Duration? delay,
  }) =>
      ServicesMock.searchServices(query, delay: delay);

  /// Toggle bookmark status with simulated delay
  static Future<bool> toggleBookmark(String serviceId, {Duration? delay}) =>
      ServicesMock.toggleBookmark(serviceId, delay: delay);

  /// Fetch reviews for a provider with simulated delay
  static Future<List<ReviewModel>> fetchReviewsForProvider(
    String providerName, {
    Duration? delay,
  }) =>
      ServicesMock.fetchReviewsForProvider(providerName, delay: delay);

  // =====================================================
  // REQUESTS DATA - Service requests (orders)
  // TODO: Move to a dedicated requests_mock.dart when scaling
  // =====================================================
  static final List<ServiceModel> requests = [
    // Upcoming requests (future dates)
    ServiceModel(
      id: 'req-upcoming-1',
      title: 'Wedding Catering Services',
      description:
          'Capturing your special moments with artistic precision and creativity. We specialize in event photography with over 8 years of experience documenting weddings, corporate events, and celebrations.',
      images: [
        'https://images.unsplash.com/photo-1519741497674-611481863552?q=80&w=1000&auto=format&fit=crop',
      ],
      type: ServiceType.catering,
      provider: ServiceProvider(
        name: 'Elite Event Photography',
        role: 'Photographer',
        imageUrl: 'https://i.pravatar.cc/150?u=user123',
        isVerified: true,
      ),
      location:
          'Airport Rd - Al Manhal - W14 02 - Abu Dhabi - United Arab Emirates',
      date: DateTime(2026, 3, 15, 16, 0), // Future date - March 15, 2026
      basePrice: 120,
      priceUnit: 'AED',
      packages: [
        ServicePackage(
          name: 'Basic',
          price: 120,
          features: [
            '4 hours coverage',
            '100 edited photos',
            'Online gallery',
            'Basic retouching',
          ],
        ),
      ],
    ),
    // Past requests (past dates)
    ServiceModel(
      id: 'req-past-1',
      title: 'Corporate Event Planning',
      description: 'Professional event planning for corporate needs.',
      images: [
        'https://images.unsplash.com/photo-1511795409834-ef04bbd61622?q=80&w=1000&auto=format&fit=crop',
      ],
      type: ServiceType.event,
      provider: ServiceProvider(
        name: 'Pro Events',
        role: 'Planner',
        imageUrl: 'https://i.pravatar.cc/150?u=user123',
        isVerified: true,
      ),
      location: 'Business Bay, Dubai',
      date: DateTime(2026, 1, 10, 16, 0), // Past date - Jan 10, 2026
      basePrice: 200,
      priceUnit: 'AED',
    ),
    ServiceModel(
      id: 'req-past-2',
      title: 'Birthday Party Décor',
      description: 'Stunning decorations for birthday parties.',
      images: [
        'https://images.unsplash.com/photo-1530103043960-ef38714abb15?q=80&w=1000&auto=format&fit=crop',
      ],
      type: ServiceType.event,
      provider: ServiceProvider(
        name: 'Decor Masters',
        role: 'Decorator',
        imageUrl: 'https://i.pravatar.cc/150?u=user123',
        isVerified: true,
      ),
      location: 'Corniche, Abu Dhabi',
      date: DateTime(2025, 12, 5, 16, 0), // Past date - Dec 5, 2025
      basePrice: 150,
      priceUnit: 'AED',
    ),
  ];
}
