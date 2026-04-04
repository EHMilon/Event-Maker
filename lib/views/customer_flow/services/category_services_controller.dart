import 'package:event_maker/models/service_model.dart';
import 'package:event_maker/services/service_repository.dart';
import 'package:get/get.dart';

/// Controller for managing services by category
/// Handles loading and filtering services based on category type
class CategoryServicesController extends GetxController {
  final ServiceRepository _repository = const ServiceRepository();
  
  final RxList<ServiceModel> services = <ServiceModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;
  
  final String categoryType;
  final String categoryName;

  CategoryServicesController({
    required this.categoryType,
    required this.categoryName,
  });

  @override
  void onInit() {
    super.onInit();
    loadServices();
  }

  /// Load services based on category type from backend API
  Future<void> loadServices() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Fetch services from backend API using customer services endpoint
      // Pass categoryName as service_as_name filter if it's different from categoryType
      // (categoryName might be "Buffet" while categoryType is "Event")
      final serviceAsFilter = categoryName != categoryType ? categoryName : null;
      
      final response = await _repository.fetchCustomerServices(
        serviceTypeName: categoryType,
        serviceAsName: serviceAsFilter,
      );
      
      // Get all services from the grouped response
      services.value = response.allServices;
    } catch (e) {
      errorMessage.value = 'Failed to load services. Please try again.';
      Get.snackbar('Error', 'Failed to load services: $e');
    } finally {
      isLoading.value = false;
    }
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
      final response = await _repository.toggleBookmark(serviceIdInt);

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
