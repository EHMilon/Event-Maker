import 'package:event_maker/models/service_model.dart';
import 'package:event_maker/mock_data/services_mock.dart';
import 'package:get/get.dart';

class ServicesController extends GetxController {
  final RxList<ServiceModel> services = <ServiceModel>[].obs;
  final RxList<ServiceModel> filteredServices = <ServiceModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxInt selectedPackageIndex = 0.obs;
  final RxString searchQuery = ''.obs;

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

  /// Load all services from the mock database
  Future<void> loadServices() async {
    try {
      isLoading.value = true;

      // Use ServicesMock API-like method with simulated network delay
      services.value = await ServicesMock.fetchAllServices(
        delay: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to load services: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void selectPackage(int index) {
    selectedPackageIndex.value = index;
  }

  /// Search services by query using mock database
  Future<void> search(String query) async {
    searchQuery.value = query;
    if (query.isEmpty) {
      filteredServices.value = services;
    } else {
      // Use the search method from ServicesMock
      filteredServices.value = await ServicesMock.searchServices(query);
    }
  }

  void clearSearch() {
    searchQuery.value = '';
    filteredServices.value = services;
  }

  /// Toggle bookmark status for a service
  Future<bool> toggleBookmark(ServiceModel service) async {
    final isBookmarked = await ServicesMock.toggleBookmark(service.id);
    
    // Update the service in the local list
    final index = services.indexWhere((s) => s.id == service.id);
    if (index != -1) {
      services[index] = service.copyWith(isBookmarked: isBookmarked);
      services.refresh();
    }
    
    return isBookmarked;
  }
}
