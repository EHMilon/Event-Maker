import 'package:event_maker/models/service_model.dart';
import 'package:event_maker/services/service_repository.dart';
import 'package:get/get.dart';

class ServicesController extends GetxController {
  final RxList<ServiceModel> services = <ServiceModel>[].obs;
  final RxList<ServiceModel> filteredServices = <ServiceModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxInt selectedPackageIndex = 0.obs;
  final RxString searchQuery = ''.obs;

  // ServiceRepository for API calls
  final ServiceRepository _serviceRepository = const ServiceRepository();

  @override
  void onInit() {
    super.onInit();
    loadServices();
    // Initialize filtered services as a copy of all services
    ever(services, (_) {
      if (searchQuery.value.isEmpty) {
        filteredServices.value = services;
      }
    });
  }

  /// Load all services from the API
  Future<void> loadServices() async {
    try {
      isLoading.value = true;

      final response = await _serviceRepository.fetchServices();
      services.value = response.services;
      filteredServices.value = response.services;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load services: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void selectPackage(int index) {
    selectedPackageIndex.value = index;
  }

  /// Search services by query using API
  Future<void> search(String query) async {
    searchQuery.value = query;
    if (query.isEmpty) {
      filteredServices.value = services;
    } else {
      filteredServices.value = services.where((service) {
        final title = service.title.toLowerCase();
        final desc = service.description?.toLowerCase() ?? '';
        final searchLower = query.toLowerCase();
        return title.contains(searchLower) || desc.contains(searchLower);
      }).toList();
    }
  }

  void clearSearch() {
    searchQuery.value = '';
    filteredServices.value = services;
  }

  /// Toggle bookmark status for a service
  /// Calls backend API: POST /services/bookmark-toggle/{serviceId}
  Future<bool> toggleBookmark(ServiceModel service) async {
    final newBookmarkState = !service.isBookmarked;

    try {
      // Parse service ID as int for API call
      final serviceIdInt = int.tryParse(
            service.id.replaceAll('service-', '').replaceAll('service-cat-', ''),
          ) ??
          0;
      final response = await _serviceRepository.toggleBookmark(serviceIdInt);

      // Use actual bookmark status from API response
      final actualBookmarkState = response.data.isBookmarked;

      // Update the service in the local list
      final index = services.indexWhere((s) => s.apiId == service.apiId || s.id == service.id);
      if (index != -1) {
        services[index] = service.copyWith(isBookmarked: actualBookmarkState);
        services.refresh();
      }

      return actualBookmarkState;
    } catch (e) {
      // On API error, still allow optimistic toggle for better UX
      // Update the service in the local list
      final index = services.indexWhere((s) => s.apiId == service.apiId || s.id == service.id);
      if (index != -1) {
        services[index] = service.copyWith(isBookmarked: newBookmarkState);
        services.refresh();
      }

      return newBookmarkState;
    }
  }
}
