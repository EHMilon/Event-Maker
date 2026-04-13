import 'dart:async';

import 'package:event_maker/models/service_model.dart';
import 'package:event_maker/services/service_repository.dart';
import 'package:event_maker/views/profile/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Controller for customer service search functionality.
/// Integrates with backend API: GET /api/services/customer-services-search?search=decor
class ServiceSearchController extends GetxController {
  late final TextEditingController searchController;
  final searchQuery = ''.obs;
  final searchResults = <ServiceModel>[].obs;
  final isLoading = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;
  final totalCount = 0.obs;

  // ServiceRepository for API calls
  final ServiceRepository _serviceRepository = const ServiceRepository();

  // Get ProfileController to sync bookmarks - will be null if not registered
  ProfileController? profileController;

  // Timer for debouncing search requests
  Timer? _searchDebounceTimer;

  @override
  void onInit() {
    super.onInit();
    searchController = TextEditingController();

    // Try to get ProfileController, but don't fail if not available
    if (Get.isRegistered<ProfileController>()) {
      profileController = Get.find<ProfileController>();
    }
  }

  @override
  void onClose() {
    _searchDebounceTimer?.cancel();
    searchController.dispose();
    super.onClose();
  }

  /// Search services by query string
  /// Calls backend API: GET /api/services/customer-services-search?search=decor
  /// Uses debouncing to avoid excessive API calls
  void searchServices(String query) {
    // Cancel any pending timer
    _searchDebounceTimer?.cancel();

    searchQuery.value = query.trim();

    if (searchQuery.value.isEmpty) {
      searchResults.clear();
      isLoading.value = false;
      hasError.value = false;
      totalCount.value = 0;
      return;
    }

    // Debounce search requests by 500ms to avoid excessive API calls
    _searchDebounceTimer = Timer(const Duration(milliseconds: 10), () {
      _performSearch(searchQuery.value);
    });
  }

  /// Perform the actual API search
  Future<void> _performSearch(String query) async {
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      final response = await _serviceRepository.searchCustomerServices(query);
      
      if (response.success) {
        // Sync bookmark status with ProfileController if available
        final services = await _syncBookmarks(response.services);
        searchResults.value = services;
        totalCount.value = response.totalCount;
        hasError.value = false;
      } else {
        searchResults.clear();
        totalCount.value = 0;
        hasError.value = true;
        errorMessage.value = response.message.isNotEmpty 
            ? response.message 
            : 'Failed to load search results';
      }
    } catch (e) {
      searchResults.clear();
      totalCount.value = 0;
      hasError.value = true;
      errorMessage.value = 'Failed to load search results. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  /// Sync bookmark status with ProfileController bookmarks
  Future<List<ServiceModel>> _syncBookmarks(List<ServiceModel> services) async {
    if (profileController == null) {
      return services;
    }

    final bookmarks = profileController!.bookmarks;
    return services.map((service) {
      final isBookmarked = bookmarks.any((b) => b.id == service.id);
      if (service.isBookmarked != isBookmarked) {
        return service.copyWith(isBookmarked: isBookmarked);
      }
      return service;
    }).toList();
  }

  /// Retry the last search (for error state)
  void retrySearch() {
    if (searchQuery.isNotEmpty) {
      _performSearch(searchQuery.value);
    }
  }

  /// Clear search and reset to show all services
  void clearSearch() {
    _searchDebounceTimer?.cancel();
    searchController.clear();
    searchQuery.value = '';
    searchResults.clear();
    totalCount.value = 0;
    hasError.value = false;
    errorMessage.value = '';
    isLoading.value = false;
  }

  /// Toggle bookmark status for a service
  /// Calls backend API: POST /services/bookmark-toggle/{serviceId}
  /// Returns true if bookmarked, false if unbookmarked
  Future<bool> toggleBookmark(String serviceId) async {
    // Find and update in search results
    final serviceIndex = searchResults.indexWhere(
      (s) => s.apiId.toString() == serviceId || s.id == serviceId,
    );
    if (serviceIndex == -1) return false;

    final service = searchResults[serviceIndex];
    final newBookmarkState = !service.isBookmarked;

    try {
      // Parse service ID as int for API call
      final serviceIdInt = int.tryParse(
            serviceId.replaceAll('service-', '').replaceAll('service-cat-', ''),
          ) ??
          0;
      
      // Call backend API to toggle bookmark
      final response = await _serviceRepository.toggleBookmark(serviceIdInt);

      // Use actual bookmark status from API response
      final actualBookmarkState = response.data.isBookmarked;

      // Update the service with new bookmark state
      searchResults[serviceIndex] = service.copyWith(
        isBookmarked: actualBookmarkState,
      );
      searchResults.refresh();

      // Sync with ProfileController bookmarks
      if (profileController != null) {
        if (actualBookmarkState) {
          // Add to bookmarks if not already present
          if (!profileController!.bookmarks.any((b) => b.id == serviceId)) {
            profileController!.bookmarks.add(searchResults[serviceIndex]);
          }
        } else {
          // Remove from bookmarks
          profileController!.bookmarks.removeWhere((b) => b.id == serviceId);
        }
        profileController!.bookmarks.refresh();
      }

      return actualBookmarkState;
    } catch (e) {
      // On API error, revert to original state for better UX
      return !newBookmarkState;
    }
  }
}
