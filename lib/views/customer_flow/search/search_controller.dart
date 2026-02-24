import 'package:event_maker/data/mock/mock_data.dart';
import 'package:event_maker/data/models/service_model.dart';
import 'package:event_maker/views/service_provider_flow/profile/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ServiceSearchController extends GetxController {
  late final TextEditingController searchController;
  final searchQuery = ''.obs;
  final searchResults = <ServiceModel>[].obs;
  final allServices = <ServiceModel>[].obs;

  // Get ProfileController to sync bookmarks - will be null if not registered
  ProfileController? profileController;

  @override
  void onInit() {
    super.onInit();
    searchController = TextEditingController();

    // Try to get ProfileController, but don't fail if not available
    if (Get.isRegistered<ProfileController>()) {
      profileController = Get.find<ProfileController>();
    }

    _loadServices();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  void _loadServices() {
    allServices.value = MockData.homeServices.map((service) {
      // Check if service is bookmarked in profileController
      final isBookmarked =
          profileController?.bookmarks.any((b) => b.id == service.id) ?? false;
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
  }

  /// Search services by title and description
  /// Returns services matching the search query (case-insensitive)
  void searchServices(String query) {
    searchQuery.value = query.trim();

    if (searchQuery.value.isEmpty) {
      searchResults.clear();
      return;
    }

    final lowercaseQuery = searchQuery.value.toLowerCase();

    searchResults.value = allServices.where((service) {
      final titleMatch = service.title.toLowerCase().contains(lowercaseQuery);
      final descriptionMatch = service.description.toLowerCase().contains(
        lowercaseQuery,
      );
      final providerMatch = service.provider.name.toLowerCase().contains(
        lowercaseQuery,
      );

      return titleMatch || descriptionMatch || providerMatch;
    }).toList();
  }

  /// Clear search and reset to show all services
  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    searchResults.clear();
  }

  /// Toggle bookmark status for a service
  /// Returns true if bookmarked, false if unbookmarked
  bool toggleBookmark(String serviceId) {
    // Find and update in allServices
    final serviceIndex = allServices.indexWhere((s) => s.id == serviceId);
    if (serviceIndex != -1) {
      final service = allServices[serviceIndex];
      final newBookmarkState = !service.isBookmarked;

      // Update the service with new bookmark state
      allServices[serviceIndex] = ServiceModel(
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
        isBookmarked: newBookmarkState,
      );

      // Also update searchResults if searching
      if (searchResults.isNotEmpty) {
        final searchIndex = searchResults.indexWhere((s) => s.id == serviceId);
        if (searchIndex != -1) {
          searchResults[searchIndex] = ServiceModel(
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
            isBookmarked: newBookmarkState,
          );
        }
      }

      // Sync with ProfileController bookmarks
      if (profileController != null) {
        if (newBookmarkState) {
          // Add to bookmarks if not already present
          if (!profileController!.bookmarks.any((b) => b.id == serviceId)) {
            profileController!.bookmarks.add(allServices[serviceIndex]);
          }
        } else {
          // Remove from bookmarks
          profileController!.bookmarks.removeWhere((b) => b.id == serviceId);
        }
      }

      // Trigger UI update
      allServices.refresh();
      searchResults.refresh();

      return newBookmarkState;
    }
    return false;
  }
}
