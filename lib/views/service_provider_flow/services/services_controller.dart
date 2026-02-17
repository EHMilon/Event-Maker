import 'package:event_maker/data/models/service_model.dart';
import 'package:event_maker/data/mock/mock_data.dart';
import 'package:event_maker/shared/utils/logger.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class ServicesController extends GetxController {
  final RxList<ServiceModel> services = <ServiceModel>[].obs;
  final RxList<ServiceModel> filteredServices = <ServiceModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxInt selectedPackageIndex = 0.obs;
  final RxString searchQuery = ''.obs;
  final TextEditingController searchController = TextEditingController();

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

  Future<void> loadServices() async {
    try {
      isLoading.value = true;
      // Simulate network check (mock)
      // var connectivityResult = await (Connectivity().checkConnectivity());
      // if (connectivityResult == ConnectivityResult.none) {
      //   Get.snackbar('Error', 'No Internet Connection');
      //   isLoading.value = false;
      //   return;
      // }

      await Future.delayed(const Duration(seconds: 2)); // Simulate API delay

      // Use centralized mock data
      services.assignAll(MockData.homeServices);
      filteredServices.assignAll(services);
      Log.success('Loaded ${services.length} provider services');
    } catch (e) {
      Get.snackbar('Error', 'Failed to load services: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void selectPackage(int index) {
    selectedPackageIndex.value = index;
  }

  void search(String query) {
    searchQuery.value = query;
    if (query.isEmpty) {
      filteredServices.value = services;
    } else {
      filteredServices.value = services.where((service) {
        final searchLower = query.toLowerCase();
        return service.title.toLowerCase().contains(searchLower) ||
            service.description.toLowerCase().contains(searchLower) ||
            service.location.toLowerCase().contains(searchLower) ||
            service.provider.name.toLowerCase().contains(searchLower);
      }).toList();
    }
  }

  void clearSearch() {
    searchQuery.value = '';
    filteredServices.value = services;
    searchController.clear();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
