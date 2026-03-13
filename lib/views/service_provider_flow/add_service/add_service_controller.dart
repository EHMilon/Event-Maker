import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/service_model.dart';
import '../services/sp_services_controller.dart';
import '../../../shared/widgets/availability_widget_card.dart';

enum ServiceCategory { hospitality, event, trainer }

enum ProviderRole { freelancer, business, productiveFamily }

class AddServiceController extends GetxController {
  static const int primaryDayLimit = 7;

  // Step 1: Details
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final locationController = TextEditingController();
  var outsideLocation = false.obs;
  var selectedImagePath = Rxn<String>();

  // Primary availability card
  late AvailabilityCardModel primaryAvailabilityCard;

  // Additional availability cards list
  var additionalAvailabilityCards = <AvailabilityCardModel>[].obs;

  final selectedCategory = ServiceCategory.hospitality.obs;
  final selectedServiceType = ServiceType.catering.obs;
  final selectedRole = ProviderRole.freelancer.obs;

  // Step 2: Packages
  var packages = <PackageFormData>[].obs;

  // Step 3: Timings
  var timings = <String, Map<String, dynamic>>{}.obs; // Day: {start: '', end: ''}

  var currentStep = 0.obs;
  var isLoading = false.obs;

  /// Initialize controller with existing service data for editing
  void initWithService(ServiceModel service) {
    titleController.text = service.title;
    descriptionController.text = service.description;
    locationController.text = service.location;
    if (service.images.isNotEmpty) {
      selectedImagePath.value = service.images.first;
    }
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
    // Set role if available (mocking logic here)
    if (service.provider.role.isNotEmpty) {
      selectedRole.value = _roleFromString(service.provider.role);
    }
  }

  @override
  void onInit() {
    super.onInit();
    // Initialize primary availability card
    primaryAvailabilityCard = AvailabilityCardModel(id: 'primary');

    // Initialize with one empty package
    if (packages.isEmpty) {
      addPackage();
    }
    // Ensures category selection is initialized for new entries
    selectedCategory.value = ServiceCategory.hospitality;
    selectedServiceType.value = ServiceType.catering;
    selectedRole.value = ProviderRole.freelancer;
  }

  /// Add a new additional availability card
  void addAdditionalAvailabilityCard() {
    final card = AvailabilityCardModel(id: DateTime.now().millisecondsSinceEpoch.toString());
    additionalAvailabilityCards.add(card);
  }

  /// Remove an additional availability card
  void removeAdditionalAvailabilityCard(String id) {
    final index = additionalAvailabilityCards.indexWhere((card) => card.id == id);
    if (index != -1) {
      additionalAvailabilityCards[index].dispose();
      additionalAvailabilityCards.removeAt(index);
    }
  }

  /// Check if additional availability is disabled (when primary card has "cannot go outside" enabled)
  /// Additional availability is enabled when "can go outside" is selected
  bool get isAdditionalAvailabilityDisabled {
    return primaryAvailabilityCard.cannotGoOutside.value;
  }

  /// Check if overlapping days are allowed (when primary card has "can go outside" enabled)
  bool get isOverlappingDaysAllowed {
    return primaryAvailabilityCard.canGoOutside.value;
  }

  /// Toggle day selection for primary availability
  void togglePrimaryDay(String day) {
    // If day is already selected in primary, just deselect it
    if (primaryAvailabilityCard.selectedDays.contains(day)) {
      primaryAvailabilityCard.selectedDays.remove(day);
      return;
    }

    // Check day limit
    if (primaryAvailabilityCard.selectedDays.length >= primaryDayLimit) {
      return;
    }

    // Add day to primary
    primaryAvailabilityCard.selectedDays.add(day);
  }

  /// Toggle day selection for additional availability card
  void toggleAdditionalDay(String cardId, String day) {
    final cardIndex = additionalAvailabilityCards.indexWhere((card) => card.id == cardId);
    if (cardIndex == -1) return;

    final card = additionalAvailabilityCards[cardIndex];

    // If day is already selected in this card, just deselect it
    if (card.selectedDays.contains(day)) {
      card.selectedDays.remove(day);
      return;
    }

    // Add day to this card
    card.selectedDays.add(day);
  }

  /// Check if a day can be selected for additional availability
  /// Days already selected in primary or other additional cards are blocked
  /// unless the primary card has "can go outside" enabled
  bool canSelectAdditionalDay(AvailabilityCardModel card, String day) {
    // Can always deselect if already selected in this card
    if (card.selectedDays.contains(day)) {
      return true;
    }

    // If primary card has "can go outside" enabled, allow overlapping days
    if (primaryAvailabilityCard.canGoOutside.value) {
      return true;
    }

    // Cannot select days that are already in primary availability
    if (primaryAvailabilityCard.selectedDays.contains(day)) {
      return false;
    }
    // Cannot select days that are in other additional cards
    for (var otherCard in additionalAvailabilityCards) {
      if (otherCard.id != card.id && otherCard.selectedDays.contains(day)) {
        return false;
      }
    }
    return true;
  }

  /// Check if a day can be selected for primary availability
  /// Days already selected in additional cards are blocked
  /// unless "can go outside" is enabled
  bool canSelectPrimaryDay(String day) {
    // Can always deselect if already selected in primary
    if (primaryAvailabilityCard.selectedDays.contains(day)) {
      return true;
    }

    // If "can go outside" is enabled, allow overlapping days
    if (primaryAvailabilityCard.canGoOutside.value) {
      return primaryAvailabilityCard.selectedDays.length < primaryDayLimit;
    }

    // Cannot select if day is in any additional card
    for (var card in additionalAvailabilityCards) {
      if (card.selectedDays.contains(day)) {
        return false;
      }
    }
    // Check day limit
    return primaryAvailabilityCard.selectedDays.length < primaryDayLimit;
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

  Future<bool> saveService({bool isEdit = false, ServiceModel? existingService}) async {
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
      id: existingService?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: titleController.text,
      description: descriptionController.text,
      location: locationController.text,
      images: selectedImagePath.value != null && selectedImagePath.value!.isNotEmpty ? [selectedImagePath.value!] : existingService?.images ?? [],
      type: selectedServiceType.value,
      provider:
          existingService?.provider ??
          ServiceProvider(name: 'Current User', role: _roleLabel(selectedRole.value), imageUrl: 'https://i.pravatar.cc/150?u=user'),
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
    Get.snackbar('Success', isEdit ? 'Service updated successfully' : 'Service added successfully');
    return true;
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    locationController.dispose();
    primaryAvailabilityCard.dispose();
    for (var card in additionalAvailabilityCards) {
      card.dispose();
    }
    super.onClose();
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

  String _roleLabel(ProviderRole role) {
    switch (role) {
      case ProviderRole.freelancer:
        return 'freelancer';
      case ProviderRole.business:
        return 'business';
      case ProviderRole.productiveFamily:
        return 'productiveFamily';
    }
  }

  ProviderRole _roleFromString(String role) {
    switch (role.toLowerCase()) {
      case 'freelancer':
        return ProviderRole.freelancer;
      case 'business':
        return ProviderRole.business;
      case 'productive family':
        return ProviderRole.productiveFamily;
      default:
        return ProviderRole.freelancer;
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
