import 'package:event_maker/data/models/service_model.dart';
import 'package:event_maker/data/mock/services_mock.dart';
import 'package:get/get.dart';

/// Controller for managing services by category
/// Handles loading and filtering services based on category type
class CategoryServicesController extends GetxController {
  final RxList<ServiceModel> services = <ServiceModel>[].obs;
  final RxBool isLoading = true.obs;
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

  /// Load services based on category type from mock database
  Future<void> loadServices() async {
    try {
      isLoading.value = true;

      // Use ServicesMock API-like method with simulated network delay
      services.value = await ServicesMock.fetchServicesByCategory(
        categoryType,
        delay: const Duration(seconds: 1),
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to load services: $e');
    } finally {
      isLoading.value = false;
    }
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
