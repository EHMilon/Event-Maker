import 'package:event_maker/mock_data/mock_data.dart';
import 'package:event_maker/models/service_model.dart';
import 'package:event_maker/services/service_repository.dart';
import 'package:event_maker/views/customer_flow/home/widgets/service_section_model.dart';
import 'package:event_maker/views/profile/profile_controller.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final ProfileController _profileController = Get.find<ProfileController>();
  final ServiceRepository _serviceRepository = const ServiceRepository();

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

  // Service groups from backend API (grouped by service_as_name)
  final serviceGroups = <ServiceGroup>[].obs;

  // User data from ProfileController
  String get userName => _profileController.userName.value;
  String get userAvatar => _profileController.profileImage.value;
  // TODO: Get from backend or location service when available
  final userLocation = ''.obs;

  // For main category selection - Default to "Event"
  final selectedMainCategory = 'Event'.obs;
  
  // For subcategory selection (null means all subcategories)
  final selectedSubCategory = RxnString();

  List<String> get currentSubCategories => subCategoriesMap[selectedMainCategory.value] ?? [];

  /// Get services filtered by selected main category and subcategory
  List<ServiceModel> get filteredServices {
    var services = allServices.toList();
    
    // Filter by main category (service_type_name)
    services = services.where((service) {
      return service.serviceTypeName.toLowerCase() == selectedMainCategory.value.toLowerCase();
    }).toList();
    
    // Filter by subcategory (service_as_name) if selected
    if (selectedSubCategory.value != null && selectedSubCategory.value!.isNotEmpty) {
      services = services.where((service) {
        return service.serviceAsName.toLowerCase() == selectedSubCategory.value!.toLowerCase();
      }).toList();
    }
    
    return services;
  }

  /// Get services grouped by service_as_name for display
  List<ServiceGroup> get displayServiceGroups {
    if (serviceGroups.isEmpty) {
      // Fallback to local grouping if no backend data
      final grouped = <String, List<ServiceModel>>{};
      for (final service in filteredServices) {
        final key = service.serviceAsName.isNotEmpty ? service.serviceAsName : 'Other';
        grouped.putIfAbsent(key, () => []).add(service);
      }
      
      return grouped.entries.map((entry) {
        return ServiceGroup(
          serviceAsName: entry.key,
          totalServices: entry.value.length,
          previewCount: entry.value.length > 5 ? 5 : entry.value.length,
          hasMore: entry.value.length > 5,
          services: entry.value.take(5).toList(),
        );
      }).toList();
    }
    
    // Use backend groups, filter by subcategory if selected
    if (selectedSubCategory.value != null && selectedSubCategory.value!.isNotEmpty) {
      return serviceGroups.where((group) => 
        group.serviceAsName.toLowerCase() == selectedSubCategory.value!.toLowerCase()
      ).toList();
    }
    
    return serviceGroups.toList();
  }

  List<ServiceModel> getServicesBySection(ServiceSectionModel section) {
    return allServices
        .where((service) => service.type == section.serviceType)
        .toList();
  }

  @override
  void onInit() {
    super.onInit();
    // Set default main category
    selectedMainCategory.value = 'Event';
    fetchHomeData();
  }

  /// Fetches all home data from backend API
  Future<void> fetchHomeData() async {
    isLoading.value = true;
    isError.value = false;
    errorMessage.value = '';

    try {
      // Set default main categories
      mainCategories.value = ['Event', 'Hospitality', 'Professional Trainer'];
      
      // Set default location - TODO: Get from backend user profile
      userLocation.value = 'New York, USA';

      // Fetch subcategories for default main category
      await _fetchSubcategories(selectedMainCategory.value);
      
      // Fetch services for default main category
      await _fetchCustomerServices();

    } catch (e) {
      isError.value = true;
      errorMessage.value = 'Failed to load home data. Please try again.';
      // Fallback to mock data on error
      await _loadMockData();
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch subcategories from backend API
  Future<void> _fetchSubcategories(String serviceTypeName) async {
    try {
      final subcategories = await _serviceRepository.fetchSubcategories(serviceTypeName);
      subCategoriesMap[serviceTypeName] = subcategories;
    } catch (e) {
      // Use fallback mock data on error
      _setMockSubCategories(serviceTypeName);
    }
  }

  /// Fetch customer services from backend API
  Future<void> _fetchCustomerServices({String? serviceAsName}) async {
    try {
      final response = await _serviceRepository.fetchCustomerServices(
        serviceTypeName: selectedMainCategory.value,
        serviceAsName: serviceAsName,
      );
      serviceGroups.value = response.data;
      
      // Also update allServices with the flattened list for compatibility
      allServices.value = response.allServices;
      
      // Update service sections based on the groups
      _updateServiceSections();
    } catch (e) {
      // On error, fall back to mock data
      await _loadMockData();
    }
  }

  /// Update main category and fetch corresponding data
  Future<void> setMainCategory(String category) async {
    if (selectedMainCategory.value == category) return;
    
    selectedMainCategory.value = category;
    selectedSubCategory.value = null; // Reset subcategory selection
    
    isLoading.value = true;
    try {
      // Fetch subcategories for new main category
      await _fetchSubcategories(category);
      
      // Fetch services for new main category
      await _fetchCustomerServices();
    } catch (e) {
      isError.value = true;
      errorMessage.value = 'Failed to load category data.';
    } finally {
      isLoading.value = false;
    }
  }

  /// Handle subcategory selection - filter services by subcategory
  Future<void> selectSubCategory(String? subCategory) async {
    // Toggle selection: if clicking same category, deselect it
    if (selectedSubCategory.value == subCategory) {
      selectedSubCategory.value = null;
    } else {
      selectedSubCategory.value = subCategory;
    }
    
    isLoading.value = true;
    try {
      // Fetch filtered services from backend
      await _fetchCustomerServices(serviceAsName: selectedSubCategory.value);
    } catch (e) {
      // On error, just update local filtering
      // The display will use local filtering via displayServiceGroups getter
    } finally {
      isLoading.value = false;
    }
  }

  /// Update service sections based on available groups
  void _updateServiceSections() {
    if (serviceGroups.isEmpty) {
      serviceSections.value = [
        const ServiceSectionModel(
          id: 'catering',
          titleKey: 'cateringServices',
          categoryName: 'cateringServices',
          serviceType: ServiceType.catering,
        ),
      ];
      return;
    }

    // Create dynamic sections based on service groups
    serviceSections.value = serviceGroups.map((group) {
      return ServiceSectionModel(
        id: group.serviceAsName.toLowerCase(),
        titleKey: group.serviceAsName,
        categoryName: group.serviceAsName,
        serviceType: ServiceType.catering, // Default, will be determined from service
      );
    }).toList();
  }

  /// Set mock subcategories for fallback
  void _setMockSubCategories(String serviceTypeName) {
    subCategoriesMap.value = {
      'Event': ['Buffet', 'Cleaning', 'Decoration', 'Furniture'],
      'Hospitality': ['Catering', 'Barista', 'Bakery', 'Waitstaff', 'Host/Hostess'],
      'Professional Trainer': ['Photographer', 'Videographer', 'Musician', 'DJ', 'MC'],
    };
  }

  /// Mock data loader - fallback implementation
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
    mainCategories.value = ['Event', 'Hospitality', 'Professional trainer'];
    _setMockSubCategories('Event');
    _setMockSubCategories('Hospitality');
    _setMockSubCategories('Professional Trainer');

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
