import 'package:event_maker/mock_data/mock_data.dart';
import 'package:event_maker/models/service_model.dart';
import 'package:event_maker/views/customer_flow/home/widgets/service_section_model.dart';
import 'package:event_maker/views/profile/profile_controller.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final ProfileController _profileController = Get.find<ProfileController>();

  final isLoading = true.obs;
  final isError = false.obs;
  final errorMessage = ''.obs;
  final searchQuery = ''.obs;
  final searchResults = <ServiceModel>[].obs;
  final allServices = <ServiceModel>[].obs;

  // Backend-compatible: categories from API
  final mainCategories = <String>[].obs;
  final subCategoriesMap = <String, List<String>>{}.obs;
  final serviceSections = <ServiceSectionModel>[].obs;

  // User data from ProfileController
  String get userName => _profileController.userName.value;
  String get userAvatar => _profileController.profileImage.value;
  // TODO: Get from backend or location service when available
  final userLocation = ''.obs;

  // For main category selection
  final selectedMainCategory = 'Event'.obs;

  List<String> get currentSubCategories => subCategoriesMap[selectedMainCategory.value] ?? [];

  List<ServiceModel> getServicesBySection(ServiceSectionModel section) {
    return allServices
        .where((service) => service.type == section.serviceType)
        .toList();
  }

  @override
  void onInit() {
    super.onInit();
    fetchHomeData();
  }

  /// Fetches all home data from backend API
  /// Replace mock implementation with actual API calls when backend is ready
  Future<void> fetchHomeData() async {
    isLoading.value = true;
    isError.value = false;
    errorMessage.value = '';

    try {
      // TODO: Replace with actual API call
      // final response = await apiService.get('/home');
      // allServices.value = response.services.map((json) => ServiceModel.fromJson(json)).toList();
      // mainCategories.value = response.categories;
      // subCategoriesMap.value = response.subCategories;
      // serviceSections.value = response.serviceSections;

      // Set default location - TODO: Get from backend user profile
      userLocation.value = 'New York, USA';

      // Backend-compatible: Load mock data (temporary)
      await _loadMockData();
    } catch (e) {
      isError.value = true;
      errorMessage.value = 'Failed to load home data. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  /// Mock data loader - temporary implementation
  /// Remove when backend is ready
  Future<void> _loadMockData() async {
    allServices.value = MockData.homeServices.map((service) {
      final isBookmarked = _profileController.bookmarks.any((b) => b.id == service.id);
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

    // Load categories from backend or fallback to mock
    mainCategories.value = ['Hospitality', 'Event', 'Professional trainer'];
    subCategoriesMap.value = {
      'Hospitality': ['Catering', 'Barista', 'Bakery', 'Waitstaff', 'Host/Hostess'],
      'Event': ['Lighting', 'Sound', 'Decoration', 'Venue', 'Planner'],
      'Professional trainer': ['Photographer', 'Videographer', 'Musician', 'DJ', 'MC'],
    };

    serviceSections.value = [
      const ServiceSectionModel(
        id: 'catering',
        titleKey: 'cateringServices',
        categoryName: 'cateringServices',
        serviceType: ServiceType.catering,
      ),
      const ServiceSectionModel(
        id: 'filming',
        titleKey: 'filmingEvents',
        categoryName: 'filmingEvents',
        serviceType: ServiceType.filming,
      ),
      const ServiceSectionModel(
        id: 'cleaning',
        titleKey: 'cleaningServices',
        categoryName: 'cleaningServices',
        serviceType: ServiceType.cleaning,
      ),
    ];

    // Keep skeleton visible for demo - remove in production
    await Future.delayed(const Duration(milliseconds: 500));
  }

  /// Toggle bookmark status for a service
  /// Calls backend API when available
  Future<bool> toggleBookmark(String serviceId) async {
    final serviceIndex = allServices.indexWhere((s) => s.id == serviceId);
    if (serviceIndex == -1) return false;

    final service = allServices[serviceIndex];
    final newBookmarkState = !service.isBookmarked;

    try {
      // TODO: Replace with actual API call
      // await apiService.post('/bookmarks', { 'serviceId': serviceId, 'bookmark': newBookmarkState });

      // Optimistic update
      allServices[serviceIndex] = service.copyWith(isBookmarked: newBookmarkState);

      if (searchResults.isNotEmpty) {
        final searchIndex = searchResults.indexWhere((s) => s.id == serviceId);
        if (searchIndex != -1) {
          searchResults[searchIndex] = searchResults[searchIndex].copyWith(isBookmarked: newBookmarkState);
        }
      }

      if (newBookmarkState) {
        if (!_profileController.bookmarks.any((b) => b.id == serviceId)) {
          _profileController.bookmarks.add(allServices[serviceIndex]);
        }
      } else {
        _profileController.bookmarks.removeWhere((b) => b.id == serviceId);
      }

      return newBookmarkState;
    } catch (e) {
      // Revert on error
      allServices[serviceIndex] = service;
      return service.isBookmarked;
    }
  }

  bool isBookmarked(String serviceId) {
    return allServices.any((s) => s.id == serviceId && s.isBookmarked) ||
           _profileController.bookmarks.any((b) => b.id == serviceId);
  }

  /// Search services - calls backend API when available
  Future<void> searchServices(String query) async {
    searchQuery.value = query.trim();

    if (searchQuery.value.isEmpty) {
      searchResults.clear();
      return;
    }

    try {
      // TODO: Replace with backend search API
      // final response = await apiService.get('/search?q=$query');
      // searchResults.value = response.services.map((json) => ServiceModel.fromJson(json)).toList();

      // Client-side search (temporary)
      final lowercaseQuery = searchQuery.value.toLowerCase();
      searchResults.value = allServices.where((service) {
        return service.title.toLowerCase().contains(lowercaseQuery) ||
               service.description.toLowerCase().contains(lowercaseQuery) ||
               service.provider.name.toLowerCase().contains(lowercaseQuery);
      }).toList();
    } catch (e) {
      searchResults.clear();
    }
  }

  void clearSearch() {
    searchQuery.value = '';
    searchResults.clear();
  }

  bool get isSearching => searchQuery.value.isNotEmpty;

  /// Refresh home data
  Future<void> refreshHomeData() async {
    await fetchHomeData();
  }
}
