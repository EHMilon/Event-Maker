import 'package:event_maker/services/service_repository.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Map Search Controller - Handles location selection and nearby service search
/// 
/// Features:
/// - Interactive map with draggable location selection
/// - Category and subcategory filtering
/// - Search nearby services based on selected location
/// - Send location data to backend for processing
class MapSearchController extends GetxController {
  final ServiceRepository _serviceRepository = const ServiceRepository();

  // Loading states
  final isLoading = false.obs;
  final isSearching = false.obs;
  final isGettingCurrentLocation = false.obs;

  // Map controller
  GoogleMapController? mapController;

  // Selected location (center of the map)
  final selectedLocation = Rx<LatLng>(const LatLng(24.4539, 54.3773)); // Default: UAE
  final selectedAddress = ''.obs;

  // Categories
  final mainCategories = <String>[].obs;
  final subCategories = <String>[].obs;
  final selectedMainCategory = RxnString();
  final selectedSubCategory = RxnString();

  // Search radius (in kilometers)
  final searchRadius = 5.0.obs;

  // Search results
  final searchResults = <dynamic>[].obs;

  // Camera position for map
  final cameraPosition = Rx<CameraPosition>(
    const CameraPosition(
      target: LatLng(24.4539, 54.3773),
      zoom: 14.0,
    ),
  );

  @override
  void onInit() {
    super.onInit();
    _initializeCategories();
    _getCurrentLocation();
  }

  @override
  void onClose() {
    mapController?.dispose();
    super.onClose();
  }

  /// Initialize categories from backend or local data
  void _initializeCategories() {
    // TODO: Fetch from backend API when available
    // For now, using the same categories as HomeController
    mainCategories.value = ['Event', 'Hospitality', 'Professional Trainer'];
    
    // Default subcategories for Event
    subCategories.value = [
      'Photographer',
      'Videographer',
      'Catering',
      'DJ',
      'Decoration',
      'Security',
    ];
  }

  /// Get current user location
  Future<void> _getCurrentLocation() async {
    isGettingCurrentLocation.value = true;
    
    try {
      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Permission denied, use default location
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Permission permanently denied, use default location
        return;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final newLocation = LatLng(position.latitude, position.longitude);
      selectedLocation.value = newLocation;
      
      // Update camera position
      cameraPosition.value = CameraPosition(
        target: newLocation,
        zoom: 14.0,
      );

      // Animate camera if map controller is ready
      if (mapController != null) {
        await mapController!.animateCamera(
          CameraUpdate.newCameraPosition(cameraPosition.value),
        );
      }

      // TODO: Reverse geocode to get address
      // For now, using coordinates as address
      selectedAddress.value = '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
      
    } catch (e) {
      debugPrint('Error getting current location: $e');
      // Use default location on error
    } finally {
      isGettingCurrentLocation.value = false;
    }
  }

  /// Update selected location when map is moved
  void onCameraMove(CameraPosition position) {
    selectedLocation.value = position.target;
  }

  /// Update location when map movement ends
  void onCameraIdle() {
    // TODO: Reverse geocode to get actual address from coordinates
    // For now, using coordinates
    selectedAddress.value = 
        '${selectedLocation.value.latitude.toStringAsFixed(4)}, ${selectedLocation.value.longitude.toStringAsFixed(4)}';
  }

  /// Set map controller when map is created
  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
    // Move camera to selected location
    mapController?.animateCamera(
      CameraUpdate.newCameraPosition(cameraPosition.value),
    );
  }

  /// Update main category selection
  Future<void> setMainCategory(String? category) async {
    if (category == null || category == selectedMainCategory.value) return;
    
    selectedMainCategory.value = category;
    selectedSubCategory.value = null; // Reset subcategory
    
    // Fetch subcategories for selected main category
    await _fetchSubcategories(category);
  }

  /// Fetch subcategories from backend
  Future<void> _fetchSubcategories(String mainCategory) async {
    isLoading.value = true;
    try {
      final subcats = await _serviceRepository.fetchSubcategories(mainCategory);
      subCategories.value = subcats;
    } catch (e) {
      debugPrint('Error fetching subcategories: $e');
      // Fallback subcategories
      subCategories.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  /// Update subcategory selection
  void setSubCategory(String? subCategory) {
    selectedSubCategory.value = subCategory;
  }

  /// Update search radius
  void setSearchRadius(double radius) {
    searchRadius.value = radius;
  }

  /// Search for nearby services
  /// 
  /// Sends location data to backend and receives nearby services
  /// Backend should return: address, latitude, longitude, and nearby services
  Future<void> searchNearbyServices() async {
    if (selectedMainCategory.value == null) {
      Get.snackbar(
        'Select Category',
        'Please select a category to search',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    isSearching.value = true;

    try {
      // Prepare search data to send to backend
      final searchData = {
        'latitude': selectedLocation.value.latitude,
        'longitude': selectedLocation.value.longitude,
        'radius': searchRadius.value,
        'main_category': selectedMainCategory.value,
        'sub_category': selectedSubCategory.value,
        // Backend will provide address from geocoding
      };

      debugPrint('Sending search data to backend: $searchData');

      // TODO: Call backend API to search nearby services
      // API endpoint should accept:
      // - latitude, longitude (user selected location)
      // - radius (search radius in km)
      // - main_category, sub_category (filters)
      // 
      // API should return:
      // - formatted_address (from reverse geocoding)
      // - confirmed_latitude, confirmed_longitude
      // - nearby_services array
      
      // Simulated API call - replace with actual API
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock response - replace with actual API response
      // After backend integration, use:
      // final response = await _serviceRepository.searchNearbyServices(searchData);
      // selectedAddress.value = response.address;
      // searchResults.value = response.services;
      
      // For now, navigate to results with selected data
      final resultData = {
        'latitude': selectedLocation.value.latitude,
        'longitude': selectedLocation.value.longitude,
        'address': selectedAddress.value,
        'main_category': selectedMainCategory.value,
        'sub_category': selectedSubCategory.value,
        'radius': searchRadius.value,
      };

      // Navigate to map results view with search data
      Get.toNamed('/map-results', arguments: resultData);
      
    } catch (e) {
      debugPrint('Error searching nearby services: $e');
      Get.snackbar(
        'Search Error',
        'Failed to search nearby services. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isSearching.value = false;
    }
  }

  /// Reset all filters
  void resetFilters() {
    selectedMainCategory.value = null;
    selectedSubCategory.value = null;
    searchRadius.value = 5.0;
    searchResults.clear();
  }

  /// Go to current location
  Future<void> goToCurrentLocation() async {
    await _getCurrentLocation();
  }
}
