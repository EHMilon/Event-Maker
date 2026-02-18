import 'package:event_maker/data/models/service_model.dart';
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

  /// TODO: Integrate with backend API
  /// Replace loadMockData with actual API call
  Future<void> fetchServices() async {
    isLoading.value = true;

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));

      // FIXME: Replace mock data with API response
      final mockServices = [
        ServiceModel(
          id: '2',
          title: 'Corporate Event Planning',
          description:
              'Professional event planning for corporate meetings, galas, and conferences.',
          images: [
            'https://images.unsplash.com/photo-1505373877841-8d25f7d46678?q=80&w=2012',
          ],
          type: ServiceType.event,
          provider: ServiceProvider(
            name: 'Sarah Smith',
            role: 'Event Expert',
            imageUrl: 'https://i.pravatar.cc/150?u=sarah',
          ),
          location: 'Business Bay, Dubai',
          basePrice: 1200,
          priceUnit: 'AED',
          date: DateTime(2026, 1, 10, 16, 0),
          rating: 4.9,
          reviewCount: 85,
        ),
        ServiceModel(
          id: '3',
          title: 'Birthday Party Décor',
          description:
              'Creative and vibrant decorations for birthday parties of all ages.',
          images: [
            'https://images.unsplash.com/photo-1530103043960-ef38714abb15?q=80&w=2069',
          ],
          type: ServiceType.event,
          provider: ServiceProvider(
            name: 'Mike Johnson',
            role: 'Vocalist',
            imageUrl: 'https://i.pravatar.cc/150?u=mike',
          ),
          location: 'Palm Jumeirah, Dubai',
          basePrice: 300,
          priceUnit: 'AED',
          date: DateTime(2026, 1, 10, 16, 0),
          rating: 4.7,
          reviewCount: 50,
        ),
      ];

      services.value = mockServices;
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
