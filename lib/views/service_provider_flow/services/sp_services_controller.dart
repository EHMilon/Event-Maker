import 'package:event_maker/models/my_service_model.dart';
import 'package:event_maker/services/service_repository.dart';
import 'package:event_maker/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SPServicesController extends GetxController {
  var isLoading = true.obs;
  var services = <MyServiceModel>[].obs;

  // Search state
  var searchQuery = ''.obs;
  var filteredServices = <MyServiceModel>[].obs;
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

  /// Fetch services from real API endpoint
  Future<void> fetchServices() async {
    isLoading.value = true;

    try {
      final response = await _repository.fetchMyServices();
      services.value = response.services;
      _filterServices();
    } catch (e) {
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
        );
      }).toList();
    }
  }

  Future<void> refreshServices() async {
    await fetchServices();
  }

  /// Add a new service to the list (called after successful creation)
  void addService(MyServiceModel service) {
    services.insert(0, service);
    _filterServices();
  }

  /// Update an existing service in the list
  void updateService(MyServiceModel updatedService) {
    final index = services.indexWhere((s) => s.id == updatedService.id);
    if (index != -1) {
      services[index] = updatedService;
      _filterServices();
    }
  }

  /// Delete a service from the list
  void deleteService(int serviceId) {
    services.removeWhere((s) => s.id == serviceId);
    _filterServices();
  }

  /// Delete service via API
  Future<bool> deleteServiceApi(int serviceId) async {
    try {
      final success = await _repository.deleteService(serviceId);
      if (success) {
        deleteService(serviceId);
        Log.d('=======> Service deleted successfully: $serviceId');
      }
      return success;
    } catch (e) {
      Log.e('=======> Failed to delete service: $e');
      rethrow;
    }
  }
}
