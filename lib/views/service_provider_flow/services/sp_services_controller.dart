import 'package:event_maker/data/models/service_model.dart';
import 'package:event_maker/data/services/service_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SPServicesController extends GetxController {
  var isLoading = true.obs;
  var services = <ServiceModel>[].obs;

  // Search state
  var searchQuery = ''.obs;
  var filteredServices = <ServiceModel>[].obs;
  final TextEditingController searchTextController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchServices();

    // Listen to search query changes
    debounce(
      searchQuery,
      (_) => _filterServices(),
      time: const Duration(milliseconds: 300),
    );
  }

  @override
  void onClose() {
    searchTextController.dispose();
    super.onClose();
  }

  final ServiceRepository _repository = const ServiceRepository();

  /// TODO: Integrate with backend API
  /// Replace loadMockData with actual API call
  Future<void> fetchServices() async {
    isLoading.value = true;

    try {
      final response = await _repository.fetchServices();
      services.value = response.services;
      _filterServices();
    } catch (e) {
      // TODO: Handle API error
      Get.snackbar('Error', 'Failed to fetch services: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
  }

  void _filterServices() {
    if (searchQuery.value.isEmpty) {
      filteredServices.value = services;
    } else {
      filteredServices.value = services.where((service) {
        return service.title.toLowerCase().contains(
              searchQuery.value.toLowerCase(),
            ) ||
            service.type.name.toLowerCase().contains(
              searchQuery.value.toLowerCase(),
            );
      }).toList();
    }
  }

  Future<void> refreshServices() async {
    await fetchServices();
  }

  /// TODO: Implement backend integration for adding service
  void addService(ServiceModel service) {
    services.insert(0, service);
    _filterServices();
  }

  /// TODO: Implement backend integration for updating service
  void updateService(ServiceModel updatedService) {
    final index = services.indexWhere((s) => s.id == updatedService.id);
    if (index != -1) {
      services[index] = updatedService;
      _filterServices();
    }
  }

  /// TODO: Implement backend integration for deleting service
  void deleteService(String serviceId) {
    services.removeWhere((s) => s.id == serviceId);
    _filterServices();
  }
}
