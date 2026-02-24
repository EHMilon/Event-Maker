import 'package:event_maker/data/mock/mock_data.dart';
import 'package:event_maker/data/models/service_model.dart';
import 'package:event_maker/views/service_provider_flow/profile/profile_controller.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final isLoading = true.obs;
  final searchQuery = ''.obs;
  final searchResults = <ServiceModel>[].obs;
  final allServices = <ServiceModel>[].obs;
  
  // For main category selection
  final selectedMainCategory = 'Event'.obs;
  final List<String> mainCategories = ['Hospitality', 'Event', 'Professional trainer'];
  
  // Sub-categories map based on main category
  final Map<String, List<String>> subCategoriesMap = {
    'Hospitality': ['Catering', 'Barista', 'Bakery', 'Waitstaff', 'Host/Hostess'],
    'Event': ['Lighting', 'Sound', 'Decoration', 'Venue', 'Planner'],
    'Professional trainer': ['Photographer', 'Videographer', 'Musician', 'DJ', 'MC'],
  };
  
  // Get current sub-categories based on selected main category
  List<String> get currentSubCategories => subCategoriesMap[selectedMainCategory.value] ?? [];

  // Get ProfileController to sync bookmarks
  final ProfileController profileController = Get.find<ProfileController>();

  @override
  void onInit() {
    super.onInit();
    fetchHomeData();
  }

  Future<void> fetchHomeData() async {
    // Load services immediately for search functionality
    allServices.value = MockData.homeServices.map((service) {
      // Check if service is bookmarked in profileController
      final isBookmarked = profileController.bookmarks.any((b) => b.id == service.id);
      return ServiceModel(
        id: service.id,
        title: service.title,
        description: service.description,
        images: service.images,
        type: service.type,
        provider: service.provider,
        location: service.location,
        rating: service.rating,
        reviewCount: service.reviewCount,
        date: service.date,
        basePrice: service.basePrice,
        priceUnit: service.priceUnit,
        packages: service.packages,
        isBookmarked: isBookmarked,
      );
    }).toList();
    
    isLoading.value = true;
    // Simulate 2s delay for skeleton loading effect
    await Future.delayed(const Duration(seconds: 2));
    isLoading.value = false;
  }

  /// Toggle bookmark status for a service
  /// Returns true if bookmarked, false if unbookmarked
  bool toggleBookmark(String serviceId) {
    // Find and update in allServices
    final serviceIndex = allServices.indexWhere((s) => s.id == serviceId);
    if (serviceIndex != -1) {
      final service = allServices[serviceIndex];
      final newBookmarkState = !service.isBookmarked;
      
      // Update the service with new bookmark state
      allServices[serviceIndex] = ServiceModel(
        id: service.id,
        title: service.title,
        description: service.description,
        images: service.images,
        type: service.type,
        provider: service.provider,
        location: service.location,
        rating: service.rating,
        reviewCount: service.reviewCount,
        date: service.date,
        basePrice: service.basePrice,
        priceUnit: service.priceUnit,
        packages: service.packages,
        isBookmarked: newBookmarkState,
      );
      
      // Also update searchResults if searching
      if (searchResults.isNotEmpty) {
        final searchIndex = searchResults.indexWhere((s) => s.id == serviceId);
        if (searchIndex != -1) {
          searchResults[searchIndex] = ServiceModel(
            id: service.id,
            title: service.title,
            description: service.description,
            images: service.images,
            type: service.type,
            provider: service.provider,
            location: service.location,
            rating: service.rating,
            reviewCount: service.reviewCount,
            date: service.date,
            basePrice: service.basePrice,
            priceUnit: service.priceUnit,
            packages: service.packages,
            isBookmarked: newBookmarkState,
          );
        }
      }
      
      // Sync with ProfileController bookmarks
      if (newBookmarkState) {
        // Add to bookmarks if not already present
        if (!profileController.bookmarks.any((b) => b.id == serviceId)) {
          profileController.bookmarks.add(allServices[serviceIndex]);
        }
      } else {
        // Remove from bookmarks
        profileController.bookmarks.removeWhere((b) => b.id == serviceId);
      }
      
      return newBookmarkState;
    }
    return false;
  }

  /// Check if a service is bookmarked
  bool isBookmarked(String serviceId) {
    return allServices.any((s) => s.id == serviceId && s.isBookmarked) ||
           profileController.bookmarks.any((b) => b.id == serviceId);
  }

  /// Search services by title and description
  /// Returns services matching the search query (case-insensitive)
  void searchServices(String query) {
    searchQuery.value = query.trim();

    if (searchQuery.value.isEmpty) {
      searchResults.clear();
      return;
    }

    final lowercaseQuery = searchQuery.value.toLowerCase();
    
    searchResults.value = allServices.where((service) {
      final titleMatch = service.title.toLowerCase().contains(lowercaseQuery);
      final descriptionMatch = service.description.toLowerCase().contains(lowercaseQuery);
      final providerMatch = service.provider.name.toLowerCase().contains(lowercaseQuery);
      
      return titleMatch || descriptionMatch || providerMatch;
    }).toList();
  }

  /// Clear search and reset to show all services
  void clearSearch() {
    searchQuery.value = '';
    searchResults.clear();
  }

  /// Check if currently searching
  bool get isSearching => searchQuery.value.isNotEmpty;

  // TODO: Add methods for filtering, sorting, etc.
  // FIXME: Handle network connectivity
}
