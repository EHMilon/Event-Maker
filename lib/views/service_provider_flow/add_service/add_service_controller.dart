import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/service_model.dart';
import '../services/sp_services_controller.dart';
import '../../../widgets/availability_widget_card.dart';

enum ServiceCategory { hospitality, event, trainer }

enum ProviderRole { freelancer, business, productiveFamily }

/// Returns available ServiceAs options based on ProviderRole and ServiceCategory
/// - Freelancer: Waitress, Barista, Juice Maker, Sandwich Maker, Burger Maker, Shawarma Maker, Chef
/// - Business: Catering, Buffet, Live Cooking, Outdoor Cafe Kiosk, Coffee Hospitality Service
/// - Productive Family: No Service As (empty list)
/// - Professional Trainer (category): Furniture, Catering
List<ServiceAs> getServiceAsOptions(
  ProviderRole role,
  ServiceCategory category,
) {
  // Professional Trainer category has Furniture, Catering
  if (category == ServiceCategory.trainer) {
    return [ServiceAs.furniture, ServiceAs.cateringTrainer];
  }

  // For other categories, options depend on role
  switch (role) {
    case ProviderRole.freelancer:
      return [
        ServiceAs.waitress,
        ServiceAs.barista,
        ServiceAs.juiceMaker,
        ServiceAs.sandwichMaker,
        ServiceAs.burgerMaker,
        ServiceAs.shawarmaMaker,
        ServiceAs.chef,
      ];
    case ProviderRole.business:
      return [
        ServiceAs.cateringBusiness,
        ServiceAs.buffet,
        ServiceAs.liveCooking,
        ServiceAs.outdoorCafeKiosk,
        ServiceAs.coffeeHospitalityService,
      ];
    case ProviderRole.productiveFamily:
      // Productive Family has no Service As field
      return [];
  }
}

/// Returns available ServiceSubOption based on ServiceAs selection
/// - Buffet: Indian Buffet, International Buffet, Japanese Buffet, Thai Buffet
/// - Live Cooking: Pastry Station, Shawarma Station, Burger Station/Pizza Station/Sushi Station
/// - Outdoor Cafe Kiosk: Outdoor Mobile Food Truck, Mobile Coffee Car/Mini Car, Coffee Cart, Outdoor Coffee Kiosk, Coffee Hospitality Service
List<ServiceSubOption> getServiceSubOptions(ServiceAs? serviceAs) {
  if (serviceAs == null) return [];

  switch (serviceAs) {
    case ServiceAs.buffet:
      return [
        ServiceSubOption.indianBuffet,
        ServiceSubOption.internationalBuffet,
        ServiceSubOption.japaneseBuffet,
        ServiceSubOption.thaiBuffet,
      ];
    case ServiceAs.liveCooking:
      return [
        ServiceSubOption.pastryStation,
        ServiceSubOption.shawarmaStation,
        ServiceSubOption.burgerPizzaSushiStation,
      ];
    case ServiceAs.outdoorCafeKiosk:
      return [
        ServiceSubOption.outdoorMobileFoodTruck,
        ServiceSubOption.mobileCoffeeCarMiniCar,
        ServiceSubOption.coffeeCart,
        ServiceSubOption.outdoorCoffeeKiosk,
        ServiceSubOption.coffeeHospitalityServiceSub,
      ];
    default:
      return [];
  }
}

class AddServiceController extends GetxController {
  static const int primaryDayLimit = 7;

  // Step 1: Details
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final locationController = TextEditingController();
  final attendanceCapacityController = TextEditingController();
  var outsideLocation = false.obs;
  var selectedImagePath = Rxn<String>();

  // Primary availability card
  late AvailabilityCardModel primaryAvailabilityCard;

  // Additional availability cards list
  var additionalAvailabilityCards = <AvailabilityCardModel>[].obs;

  final selectedCategory = ServiceCategory.hospitality.obs;
  final selectedServiceType = ServiceType.catering.obs;
  final selectedRole = ProviderRole.freelancer.obs;
  final selectedServiceAs = Rxn<ServiceAs>();
  final selectedEventVenue = Rxn<EventVenue>();
  final selectedSubOptions = <ServiceSubOption>[].obs;

  /// Returns available ServiceAs options based on current selected role and category
  List<ServiceAs> get availableServiceAsOptions =>
      getServiceAsOptions(selectedRole.value, selectedCategory.value);

  /// Returns true if Event Venue dropdown should be shown (when category is Event)
  bool get showEventVenueDropdown =>
      selectedCategory.value == ServiceCategory.event;

  /// Returns available sub-options based on selected ServiceAs
  List<ServiceSubOption> get availableSubOptions =>
      getServiceSubOptions(selectedServiceAs.value);

  /// Returns true if sub-options checklist should be shown (Event + Business + Buffet/LiveCooking/OutdoorCafeKiosk)
  bool get showSubOptionsChecklist =>
      selectedCategory.value == ServiceCategory.event &&
      selectedRole.value == ProviderRole.business &&
      (selectedServiceAs.value == ServiceAs.buffet ||
          selectedServiceAs.value == ServiceAs.liveCooking ||
          selectedServiceAs.value == ServiceAs.outdoorCafeKiosk);

  /// Returns available ProviderRole options based on selected category
  /// - Event: only Business role is available
  /// - Trainer: Business and Productive Family (no Freelancer)
  /// - Hospitality: All roles available
  List<ProviderRole> get availableRoleOptions {
    if (selectedCategory.value == ServiceCategory.event) {
      return [ProviderRole.business];
    }
    if (selectedCategory.value == ServiceCategory.trainer) {
      return [ProviderRole.business, ProviderRole.productiveFamily];
    }
    return ProviderRole.values;
  }

  /// Returns true if attendance capacity fields should be shown
  /// Shown for Event and Trainer categories
  bool get showAttendanceCapacity =>
      selectedCategory.value == ServiceCategory.event ||
      selectedCategory.value == ServiceCategory.trainer;

  /// Returns true if Service As can be added dynamically (Trainer category)
  bool get canAddMoreServiceAs =>
      selectedCategory.value == ServiceCategory.trainer;

  /// List of additional custom Service As entries for Trainer category
  var additionalServiceAsList = <String>[].obs;

  /// Controller for the new Service As text input
  final newServiceAsController = TextEditingController();

  /// Toggle for showing/hiding the add Service As text field
  var showAddServiceAsField = false.obs;

  /// Show the add Service As text field (called when + button is clicked)
  void addCustomServiceAsDirectly() {
    showAddServiceAsField.value = true;
  }

  /// Close/hide the add Service As text field
  void closeAddServiceAsField() {
    showAddServiceAsField.value = false;
    newServiceAsController.clear();
  }

  /// Add a new custom Service As to the additional list
  void addCustomServiceAs() {
    final value = newServiceAsController.text.trim();
    if (value.isNotEmpty && !additionalServiceAsList.contains(value)) {
      additionalServiceAsList.add(value);
      newServiceAsController.clear();
      showAddServiceAsField.value = false;
    }
  }

  /// Remove a custom Service As from the additional list
  void removeCustomServiceAs(String serviceAs) {
    additionalServiceAsList.remove(serviceAs);
  }

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
    // Set serviceAs if available
    if (service.serviceAs != null) {
      selectedServiceAs.value = service.serviceAs;
    }
    // Set eventVenue if available
    if (service.eventVenue != null) {
      selectedEventVenue.value = service.eventVenue;
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
    final card = AvailabilityCardModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
    );
    additionalAvailabilityCards.add(card);
  }

  /// Remove an additional availability card
  void removeAdditionalAvailabilityCard(String id) {
    final index = additionalAvailabilityCards.indexWhere(
      (card) => card.id == id,
    );
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
    final cardIndex = additionalAvailabilityCards.indexWhere(
      (card) => card.id == cardId,
    );
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
    // Reset ServiceAs when category changes since options depend on category
    selectedServiceAs.value = null;
    // Reset additional ServiceAs list when category changes
    additionalServiceAsList.clear();
    // Reset EventVenue when category changes
    selectedEventVenue.value = null;
    // Reset subOptions when category changes
    selectedSubOptions.clear();
    // When Event category is selected, auto-select Business role
    if (category == ServiceCategory.event) {
      selectedRole.value = ProviderRole.business;
    }
    // When Trainer category is selected, reset role if freelancer (not allowed)
    else if (category == ServiceCategory.trainer) {
      if (selectedRole.value == ProviderRole.freelancer) {
        selectedRole.value = ProviderRole.business;
      }
    }
    if (_categoryFromServiceType(selectedServiceType.value) == category) {
      return;
    }
    selectedServiceType.value = _defaultTypeForCategory(category);
  }

  /// Toggle a sub-option selection
  void toggleSubOption(ServiceSubOption option) {
    if (selectedSubOptions.contains(option)) {
      selectedSubOptions.remove(option);
    } else {
      selectedSubOptions.add(option);
    }
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
      images:
          selectedImagePath.value != null && selectedImagePath.value!.isNotEmpty
          ? [selectedImagePath.value!]
          : existingService?.images ?? [],
      type: selectedServiceType.value,
      provider:
          existingService?.provider ??
          ServiceProvider(
            name: 'Current User',
            role: _roleLabel(selectedRole.value),
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
      serviceAs: selectedServiceAs.value,
      eventVenue: selectedEventVenue.value,
      subOptions: selectedSubOptions.isNotEmpty
          ? selectedSubOptions.toList()
          : null,
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
    attendanceCapacityController.dispose();
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
