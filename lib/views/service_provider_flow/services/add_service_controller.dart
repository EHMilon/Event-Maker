import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/service_model.dart';
import '../../../views/service_provider_flow/services/sp_services_controller.dart';

enum ServiceCategory { hospitality, event, trainer }

class AddServiceController extends GetxController {
  static const int primaryDayLimit = 7;
  // Step 1: Details
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final locationController = TextEditingController();
  var outsideLocation = false.obs;
  var availability = <String>[].obs; // Days like 'Mon', 'Tue'
  var additionalAvailability = <String>[].obs;
  var showAdditionalAvailability = false.obs;
  final additionalLocationController = TextEditingController();
  final startTime = Rxn<TimeOfDay>();
  final endTime = Rxn<TimeOfDay>();
  final selectedCategory = ServiceCategory.hospitality.obs;
  final selectedServiceType = ServiceType.catering.obs;

  // Step 2: Packages
  var packages = <PackageFormData>[].obs;

  // Step 3: Timings
  var timings =
      <String, Map<String, dynamic>>{}.obs; // Day: {start: '', end: ''}

  var currentStep = 0.obs;
  var isLoading = false.obs;

  /// Initialize controller with existing service data for editing
  void initWithService(ServiceModel service) {
    titleController.text = service.title;
    descriptionController.text = service.description;
    locationController.text = service.location;
    selectedServiceType.value = service.type;
    selectedCategory.value = _categoryFromServiceType(service.type);
    if (service.packages != null) {
      packages.clear();
      for (var package in service.packages!) {
        final sp = PackageFormData();
        sp.nameController.text = package.name;
        sp.priceController.text = package.price.toString();
        sp.features.clear();
        sp.features.addAll(package.features);
        packages.add(sp);
      }
    }
  }

  @override
  void onInit() {
    super.onInit();
    // Initialize with one empty package
    if (packages.isEmpty) {
      addPackage();
    }
    // Ensures category selection is initialized for new entries
    selectedCategory.value = ServiceCategory.hospitality;
    selectedServiceType.value = ServiceType.catering;
  }

  void addPackage() {
    packages.add(PackageFormData());
  }

  void removePackage(int index) {
    if (packages.length > 1) {
      packages.removeAt(index);
    }
  }

  void updateCategory(ServiceCategory category) {
    selectedCategory.value = category;
    if (_categoryFromServiceType(selectedServiceType.value) == category) {
      return;
    }
    selectedServiceType.value = _defaultTypeForCategory(category);
  }

  Future<bool> saveService({
    bool isEdit = false,
    ServiceModel? existingService,
  }) async {
    isLoading.value = true;
    // Network Rules: 2s delay for shimmer/loading state visibility
    await Future.delayed(const Duration(seconds: 2));

    // TODO: Validate required fields (title, description, location)
    // TODO: Call Backend API to save/update service
    // Example:
    // try {
    //   final response = await _apiService.post('/services', data: newService.toJson());
    //   if (response.statusCode == 200) { ... }
    // } catch (e) { ... }

    // Create the service model from form data (Placeholder until Backend)
    final newService = ServiceModel(
      id:
          existingService?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      title: titleController.text,
      description: descriptionController.text,
      location: locationController.text,
      images: existingService?.images ?? [],
      type: selectedServiceType.value,
      provider:
          existingService?.provider ??
          ServiceProvider(
            name: 'Current User',
            role: 'Service Provider',
            imageUrl: 'https://i.pravatar.cc/150?u=user',
          ),
      basePrice: 0,
      priceUnit: 'AED',
      packages: packages
          .map(
            (p) => ServicePackage(
              name: p.nameController.text,
              price: double.tryParse(p.priceController.text) ?? 0,
              features: p.features.where((f) => f.isNotEmpty).toList(),
            ),
          )
          .toList(),
    );

    // Update the services list
    final spController = Get.find<SPServicesController>();
    if (isEdit && existingService != null) {
      spController.updateService(newService);
    } else {
      spController.addService(newService);
    }

    isLoading.value = false;
    Get.back(result: true);
    Get.snackbar(
      'Success',
      isEdit ? 'Service updated successfully' : 'Service added successfully',
    );
    return true;
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    locationController.dispose();
    additionalLocationController.dispose();
    super.onClose();
  }

  void togglePrimaryDay(String day) {
    if (availability.contains(day)) {
      availability.remove(day);
      return;
    }
    if (availability.length >= primaryDayLimit) {
      return;
    }
    availability.add(day);
    if (additionalAvailability.contains(day)) {
      additionalAvailability.remove(day);
    }
  }

  void toggleAdditionalDay(String day) {
    if (!canSelectAdditionalDay(day)) {
      return;
    }
    if (additionalAvailability.contains(day)) {
      additionalAvailability.remove(day);
      return;
    }
    additionalAvailability.add(day);
  }

  void toggleAdditionalSection() {
    showAdditionalAvailability.value = !showAdditionalAvailability.value;
  }

  bool canSelectAdditionalDay(String day) {
    if (additionalAvailability.contains(day)) {
      return true;
    }
    if (availability.contains(day)) {
      return false;
    }
    return true;
  }

  bool canSelectPrimaryDay(String day) {
    if (availability.contains(day)) {
      return true;
    }
    return availability.length < primaryDayLimit;
  }

  ServiceCategory _categoryFromServiceType(ServiceType type) {
    switch (type) {
      case ServiceType.event:
        return ServiceCategory.event;
      case ServiceType.training:
        return ServiceCategory.trainer;
      default:
        return ServiceCategory.hospitality;
    }
  }

  ServiceType _defaultTypeForCategory(ServiceCategory category) {
    switch (category) {
      case ServiceCategory.event:
        return ServiceType.event;
      case ServiceCategory.trainer:
        return ServiceType.training;
      case ServiceCategory.hospitality:
        return ServiceType.catering;
    }
  }
}

class PackageFormData {
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  var features = <String>[].obs;

  PackageFormData() {
    features.add(''); // Start with one empty feature
  }
}
