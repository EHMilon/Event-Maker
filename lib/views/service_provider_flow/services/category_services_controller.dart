import 'package:event_maker/data/models/service_model.dart';
import 'package:event_maker/data/mock/mock_data.dart';
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

  /// Load services based on category type
  Future<void> loadServices() async {
    try {
      isLoading.value = true;
      
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Get services by category type
      if (categoryType == 'all') {
        // Show all services when 'all' is selected
        services.value = MockData.homeServices;
      } else {
        services.value = MockData.getHomeSectionServices(categoryType);
      }
      
    } catch (e) {
      Get.snackbar('Error', 'Failed to load services: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Get ServiceType from string category type
  ServiceType _getServiceType(String type) {
    final typeMap = {
      'catering': ServiceType.catering,
      'filming': ServiceType.filming,
      'cleaning': ServiceType.cleaning,
      'music': ServiceType.music,
      'photography': ServiceType.photography,
      'event': ServiceType.event,
    };
    return typeMap[type] ?? ServiceType.event;
  }
}
