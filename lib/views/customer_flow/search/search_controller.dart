import 'package:event_maker/mock_data/mock_data.dart';
import 'package:event_maker/models/service_model.dart';
import 'package:event_maker/services/service_repository.dart';
import 'package:event_maker/views/profile/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ServiceSearchController extends GetxController {
  late final TextEditingController searchController;
  final searchQuery = ''.obs;
  final searchResults = <ServiceModel>[].obs;
  final allServices = <ServiceModel>[].obs;

  // ServiceRepository for API calls
  final ServiceRepository _serviceRepository = const ServiceRepository();

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
  /// Calls backend API: POST /services/bookmark-toggle/{serviceId}
  /// Returns true if bookmarked, false if unbookmarked
  Future<bool> toggleBookmark(String serviceId) async {
    // Find and update in allServices - check both apiId and legacy id
    final serviceIndex = allServices.indexWhere((s) => s.apiId.toString() == serviceId || s.id == serviceId);
    if (serviceIndex == -1) return false;

    final service = allServices[serviceIndex];
    final newBookmarkState = !service.isBookmarked;

    try {
      // Call backend API to toggle bookmark
      // Parse service ID as int for API call
      final serviceIdInt = int.tryParse(
            serviceId.replaceAll('service-', '').replaceAll('service-cat-', ''),
          ) ??
          0;
      final response = await _serviceRepository.toggleBookmark(serviceIdInt);

      // Use actual bookmark status from API response
      final actualBookmarkState = response.data.isBookmarked;

      // Update the service with new bookmark state
      allServices[serviceIndex] = service.copyWith(isBookmarked: actualBookmarkState);

      // Also update searchResults if searching
      if (searchResults.isNotEmpty) {
        final searchIndex = searchResults.indexWhere((s) => s.id == serviceId);
        if (searchIndex != -1) {
          searchResults[searchIndex] = searchResults[searchIndex].copyWith(
            isBookmarked: actualBookmarkState,
          );
        }
      }

      // Sync with ProfileController bookmarks
      if (profileController != null) {
        if (actualBookmarkState) {
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

      return actualBookmarkState;
    } catch (e) {
      // On API error, still allow optimistic toggle for better UX
      // Update the service with new bookmark state
      allServices[serviceIndex] = service.copyWith(isBookmarked: newBookmarkState);

      // Also update searchResults if searching
      if (searchResults.isNotEmpty) {
        final searchIndex = searchResults.indexWhere((s) => s.id == serviceId);
        if (searchIndex != -1) {
          searchResults[searchIndex] = searchResults[searchIndex].copyWith(
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
  }
}
