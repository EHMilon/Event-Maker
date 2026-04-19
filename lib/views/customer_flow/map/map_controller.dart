import 'package:event_maker/views/customer_flow/map/map_results_view.dart';
import 'package:event_maker/services/service_repository.dart';
import 'package:event_maker/constants/env_config.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../widgets/google_map.dart';

/// MapController - Handles map search form logic
///
/// Features:
/// - Location selection via GoogleMapScreen picker
/// - Category and subcategory selection
/// - Navigate to map results with search parameters
class MapController extends GetxController {
  final ServiceRepository _serviceRepository = const ServiceRepository();

  final isLoading = false.obs;

  // Selected location data
  final selectedLatitude = Rxn<double>();
  final selectedLongitude = Rxn<double>();
  final selectedAddress = ''.obs;

  final selectedMainCategory = 'Event'.obs;
  final mainCategories = ['Event', 'Hospitality', 'Professional Trainer'];

  final selectedSubCategories = <String>[].obs;
  final subCategories = <Map<String, dynamic>>[].obs;

  // Cache for subcategories by main category
  final Map<String, List<String>> _subCategoriesCache = {};

  @override
  void onInit() {
    super.onInit();
    _requestLocationPermission();
    ever(selectedMainCategory, (_) => fetchSubCategories());
    fetchSubCategories();
  }

  Future<void> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
  }

  /// Fetch subcategories from API based on selected main category
  Future<void> fetchSubCategories() async {
    isLoading.value = true;
    try {
      final categoryName = selectedMainCategory.value;

      // Check cache first
      if (_subCategoriesCache.containsKey(categoryName)) {
        _updateSubCategoriesFromList(_subCategoriesCache[categoryName]!);
        isLoading.value = false;
        return;
      }

      // Fetch from API
      final subcategoriesList = await _serviceRepository.fetchSubcategories(
        categoryName,
      );

      // Cache the result
      _subCategoriesCache[categoryName] = subcategoriesList;

      // Update UI
      _updateSubCategoriesFromList(subcategoriesList);
    } catch (e) {
      debugPrint('Error fetching subcategories: $e');
      Get.snackbar(
        'Error',
        'Failed to load subcategories. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Update subcategories list from fetched data
  void _updateSubCategoriesFromList(List<String> subcategoriesList) {
    // Convert to map format for the UI
    subCategories.assignAll(
      subcategoriesList.map((name) => {'name': name}).toList(),
    );

    // Clear selected sub-categories when changing main category
    selectedSubCategories.clear();
  }

  void toggleSubCategory(String name) {
    if (selectedSubCategories.contains(name)) {
      selectedSubCategories.remove(name);
    } else {
      selectedSubCategories.add(name);
    }
  }

  void selectAll() {
    if (selectedSubCategories.length == subCategories.length) {
      selectedSubCategories.clear();
    } else {
      selectedSubCategories.assignAll(
        subCategories.map((e) => e['name'] as String).toList(),
      );
    }
  }

  /// Open location picker using GoogleMapScreen
  Future<void> openLocationPicker() async {
    // Default to Dubai if no location selected
    final initialPosition =
        (selectedLatitude.value != null && selectedLongitude.value != null)
        ? LatLng(selectedLatitude.value!, selectedLongitude.value!)
        : const LatLng(25.2048, 55.2708); // Dubai default

    // Use a local variable to capture the selected location
    GoogleMapLocation? selectedLocation;

    await Get.to(
      () => GoogleMapScreen(
        apiKey: EnvConfig.googleMapsApiKey,
        initialPosition: initialPosition,
        withScaffold: true,
        canSelectLocation: true,
        useDarkStyle: true,
        onLocationSelect: (location) {
          selectedLocation = location;
        },
      ),
    );

    // Update the selected location after the screen is closed
    if (selectedLocation != null) {
      selectedLatitude.value = selectedLocation!.position.latitude;
      selectedLongitude.value = selectedLocation!.position.longitude;
      selectedAddress.value = selectedLocation!.name;
    }
  }

  Future<void> search() async {
    // Validate location is selected
    if (selectedLatitude.value == null || selectedLongitude.value == null) {
      Get.snackbar(
        'Select Location',
        'Please select a location to search',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    // Validate at least one subcategory is selected
    if (selectedSubCategories.isEmpty) {
      Get.snackbar(
        'Select Subcategory',
        'Please select at least one subcategory',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;

    try {
      // Prepare search parameters
      final searchParams = {
        'latitude': selectedLatitude.value!,
        'longitude': selectedLongitude.value!,
        'service_type_name': selectedMainCategory.value,
        'service_as_names': selectedSubCategories.join(','),
      };

      debugPrint('Searching with params: $searchParams');

      // Call the search API
      final response = await _serviceRepository.searchMapServices(searchParams);

      if (response['success'] == true) {
        // Navigate to results view with the received data
        Get.to(
          () => const MapResultsView(),
          arguments: {...searchParams, 'api_data': response['data']},
          transition: Transition.fadeIn,
        );
      } else {
        Get.snackbar(
          'Search Error',
          response['message'] ?? 'Failed to retrieve results',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('Error during search: $e');
      Get.snackbar(
        'Error',
        'Failed to initiate search. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
