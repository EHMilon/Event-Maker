import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/service_model.dart';
import '../../../models/my_service_model.dart';
import '../../../models/service_request_model.dart';
import '../../../services/service_repository.dart';
import '../../../services/api_exception.dart';
import '../../../utils/logger.dart';
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

  final selectedServiceAsItems =
      <dynamic>[].obs; // Can hold ServiceAs enum or String

  final selectedEventVenue = Rxn<EventVenue>();
  final selectedEventVenueItems = <dynamic>[].obs; // Can hold EventVenue enum or String

  /// Controller for the new Event Venue text input
  final newEventVenueController = TextEditingController();

  /// Toggle for showing/hiding the add Event Venue text field
  var showAddEventVenueField = false.obs;

  final selectedSubOptions = <ServiceSubOption>[].obs;
  final selectedSubOptionsItems =
      <dynamic>[].obs; // Can hold ServiceSubOption enum or String

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

  /// Returns available ProviderRole options - all roles available for all categories
  /// Freelancer, Business, and Productive Family are shown regardless of service type
  List<ProviderRole> get availableRoleOptions {
    return ProviderRole.values;
  }

  /// Returns true if attendance capacity fields should be shown
  /// Shown for Event and Trainer categories
  bool get showAttendanceCapacity =>
      selectedCategory.value == ServiceCategory.event ||
      selectedCategory.value == ServiceCategory.trainer;

  /// Returns true if Service As can be added dynamically
  bool get canAddMoreServiceAs =>
      true; // Enabled for all categories per user request

  /// Controller for the new Service As text input
  final newServiceAsController = TextEditingController();

  /// Toggle for showing/hiding the add Service As text field
  var showAddServiceAsField = false.obs;

  /// Controller for the new Sub Option text input
  final newSubOptionController = TextEditingController();

  /// Toggle for showing/hiding the add Sub Option text field
  var showAddSubOptionField = false.obs;

  /// Show the add Service As text field (called when + button is clicked)
  void addCustomServiceAsDirectly() {
    showAddServiceAsField.value = true;
  }

  /// Close/hide the add Service As text field
  void closeAddServiceAsField() {
    showAddServiceAsField.value = false;
    newServiceAsController.clear();
  }

  /// Add a new custom Service As to the selection
  void addCustomServiceAs() {
    final value = newServiceAsController.text.trim();
    if (value.isNotEmpty) {
      selectedServiceAsItems.clear(); // Enforce single selection
      selectedServiceAsItems.add(value);
      newServiceAsController.clear();
      showAddServiceAsField.value = false;
    }
  }

  /// Toggle ServiceAs selection
  void toggleServiceAs(dynamic item) {
    if (selectedServiceAsItems.contains(item)) {
      selectedServiceAsItems.remove(item);
      if (item is ServiceAs && selectedServiceAs.value == item) {
        selectedServiceAs.value = null;
      }
    } else {
      selectedServiceAsItems.clear(); // Enforce single selection
      selectedServiceAsItems.add(item);
      if (item is ServiceAs) {
        selectedServiceAs.value = item;
      } else {
        selectedServiceAs.value = null;
      }
    }
  }

  /// Remove a Service As from the selection
  void removeServiceAs(dynamic item) {
    selectedServiceAsItems.remove(item);
    if (item is ServiceAs && selectedServiceAs.value == item) {
      selectedServiceAs.value = null;
    }
  }

  /// Show the add Sub Option text field
  void addCustomSubOptionDirectly() {
    showAddSubOptionField.value = true;
  }

  /// Close/hide the add Sub Option text field
  void closeAddSubOptionField() {
    showAddSubOptionField.value = false;
    newSubOptionController.clear();
  }

  /// Add a new custom Sub Option to the selection
  void addCustomSubOption() {
    final value = newSubOptionController.text.trim();
    if (value.isNotEmpty) {
      selectedSubOptionsItems.clear(); // Enforce single selection
      selectedSubOptionsItems.add(value);
      newSubOptionController.clear();
      showAddSubOptionField.value = false;
    }
  }

  /// Toggle SubOption selection
  void toggleSubOptionItem(dynamic item) {
    if (selectedSubOptionsItems.contains(item)) {
      selectedSubOptionsItems.remove(item);
      if (item is ServiceSubOption) {
        selectedSubOptions.remove(item);
      }
    } else {
      selectedSubOptionsItems.clear(); // Enforce single selection
      selectedSubOptions.clear();
      selectedSubOptionsItems.add(item);
      if (item is ServiceSubOption) {
        selectedSubOptions.add(item);
      }
    }
  }

  /// Remove a Sub Option from the selection
  void removeSubOptionItem(dynamic item) {
    selectedSubOptionsItems.remove(item);
    if (item is ServiceSubOption) {
      selectedSubOptions.remove(item);
    }
  }

  /// Show the add Event Venue text field (called when + button is clicked)
  void addCustomEventVenueDirectly() {
    showAddEventVenueField.value = true;
  }

  /// Close/hide the add Event Venue text field
  void closeAddEventVenueField() {
    showAddEventVenueField.value = false;
    newEventVenueController.clear();
  }

  /// Add a new custom Event Venue to the selection
  void addCustomEventVenue() {
    final value = newEventVenueController.text.trim();
    if (value.isNotEmpty) {
      selectedEventVenueItems.clear(); // Enforce single selection
      selectedEventVenueItems.add(value);
      newEventVenueController.clear();
      showAddEventVenueField.value = false;
    }
  }

  /// Toggle EventVenue selection
  void toggleEventVenue(dynamic item) {
    if (selectedEventVenueItems.contains(item)) {
      selectedEventVenueItems.remove(item);
      if (item is EventVenue && selectedEventVenue.value == item) {
        selectedEventVenue.value = null;
      }
    } else {
      selectedEventVenueItems.clear(); // Enforce single selection
      selectedEventVenueItems.add(item);
      if (item is EventVenue) {
        selectedEventVenue.value = item;
      } else {
        selectedEventVenue.value = null;
      }
    }
  }

  /// Remove an Event Venue from the selection
  void removeEventVenue(dynamic item) {
    selectedEventVenueItems.remove(item);
    if (item is EventVenue && selectedEventVenue.value == item) {
      selectedEventVenue.value = null;
    }
  }

  // Step 2: Packages
  var packages = <PackageFormData>[].obs;
  var needsConfirmationBeforePayment = false.obs;

  // Step 3: Timings
  var timings =
      <String, Map<String, dynamic>>{}.obs; // Day: {start: '', end: ''}

  var currentStep = 0.obs;
  var isLoading = false.obs;

  /// Initialize controller with existing service data for editing
  void initWithService(ServiceModel service) {
    // Basic fields
    titleController.text = service.title;
    descriptionController.text = service.description;

    // Location - use first availability address or fallback to service.location
    // Set both locationController and primaryAvailabilityCard.locationController for UI consistency
    String locationValue = '';
    if (service.availabilities.isNotEmpty &&
        service.availabilities[0].address.isNotEmpty) {
      locationValue = service.availabilities[0].address;
    } else if (service.location.isNotEmpty) {
      locationValue = service.location;
    }
    locationController.text = locationValue;
    // Important: The widget uses locationController, not addressController
    primaryAvailabilityCard.locationController.text = locationValue;
    primaryAvailabilityCard.addressController.text = locationValue;

    // Cover image
    if (service.coverImage.isNotEmpty) {
      selectedImagePath.value = service.coverImage;
    } else if (service.images.isNotEmpty) {
      selectedImagePath.value = service.images.first;
    }

    // Service type and category
    selectedServiceType.value = service.type;
    selectedCategory.value = _categoryFromServiceType(service.type);

    // Role - map from roleName string
    if (service.roleName.isNotEmpty) {
      selectedRole.value = _roleFromString(service.roleName);
    }

    // ServiceAs - map from serviceAsName string
    if (service.serviceAsName.isNotEmpty) {
      final serviceAs = _serviceAsFromString(service.serviceAsName);
      if (serviceAs != null) {
        selectedServiceAs.value = serviceAs;
        selectedServiceAsItems.clear();
        selectedServiceAsItems.add(serviceAs);
      }
    }

    // Event Venue
    if (service.eventVenue != null) {
      final eventVenue = _eventVenueFromString(service.eventVenue);
      selectedEventVenue.value = eventVenue;
      selectedEventVenueItems.clear();
      if (eventVenue != null) {
        selectedEventVenueItems.add(eventVenue);
      } else {
        // If not mapped to enum, use as custom string
        selectedEventVenueItems.add(service.eventVenue);
      }
    }

    // Attendance Capacity
    if (service.attendanceCapacity != null) {
      attendanceCapacityController.text = service.attendanceCapacity.toString();
    }

    // Outside location settings
    if (service.canGoOutsideLocation) {
      primaryAvailabilityCard.canGoOutside.value = true;
    }
    if (service.canNotGoOutsideLocation) {
      primaryAvailabilityCard.cannotGoOutside.value = true;
    }

    // Requires confirmation
    needsConfirmationBeforePayment.value = service.requiresConfirmation;

    // Options (sub-options)
    if (service.options != null && service.options!.isNotEmpty) {
      selectedSubOptionsItems.clear();
      selectedSubOptionsItems.add(service.options!);
    }

    // Packages
    if (service.packages.isNotEmpty) {
      // Clear existing packages first
      for (var pkg in packages) {
        pkg.dispose();
      }
      packages.clear();
      for (var package in service.packages) {
        final sp = PackageFormData();
        sp.nameController.text = package.name;
        sp.priceController.text = package.price;
        // Clear default empty feature first
        sp.featureControllers.clear();
        // Add each feature title with initial value using feature controllers
        for (var feature in package.features) {
          // Extract the title string from the PackageFeature object
          final featureTitle = feature.title;
          if (featureTitle.isNotEmpty) {
            sp.addFeature(featureTitle);
          }
        }
        packages.add(sp);
      }
    }

    // Availabilities
    if (service.availabilities.isNotEmpty) {
      // First availability goes to primary card
      final firstAvailability = service.availabilities[0];
      primaryAvailabilityCard.selectedDays.value = firstAvailability.weekDays;
      primaryAvailabilityCard.addressController.text =
          firstAvailability.address;
      primaryAvailabilityCard.latitude.value = firstAvailability.latitude;
      primaryAvailabilityCard.longitude.value = firstAvailability.longitude;
      // Parse time strings to TimeOfDay
      primaryAvailabilityCard.startTime.value = _parseTimeString(
        firstAvailability.startTime,
      );
      primaryAvailabilityCard.endTime.value = _parseTimeString(
        firstAvailability.endTime,
      );

      // Additional availabilities
      for (var i = 1; i < service.availabilities.length; i++) {
        final availability = service.availabilities[i];
        final card = AvailabilityCardModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
        );
        card.selectedDays.value = availability.weekDays;
        card.addressController.text = availability.address;
        card.latitude.value = availability.latitude;
        card.longitude.value = availability.longitude;
        card.startTime.value = _parseTimeString(availability.startTime);
        card.endTime.value = _parseTimeString(availability.endTime);
        additionalAvailabilityCards.add(card);
      }
    }
  }

  /// Parse time string (HH:MM:SS) to TimeOfDay
  TimeOfDay _parseTimeString(String time) {
    if (time.isEmpty) return const TimeOfDay(hour: 9, minute: 0);
    final parts = time.split(':');
    if (parts.length >= 2) {
      return TimeOfDay(
        hour: int.tryParse(parts[0]) ?? 9,
        minute: int.tryParse(parts[1]) ?? 0,
      );
    }
    return const TimeOfDay(hour: 9, minute: 0);
  }

  /// Map serviceAsName string to ServiceAs enum
  ServiceAs? _serviceAsFromString(String name) {
    if (name.isEmpty) return null;
    final lowerName = name.toLowerCase().trim();
    for (final serviceAs in ServiceAs.values) {
      if (serviceAs.label.toLowerCase() == lowerName) {
        return serviceAs;
      }
    }
    // Try partial matches
    switch (lowerName) {
      case 'waitress':
        return ServiceAs.waitress;
      case 'barista':
      case 'barista (hot drinks)':
        return ServiceAs.barista;
      case 'juice maker':
        return ServiceAs.juiceMaker;
      case 'sandwich maker':
        return ServiceAs.sandwichMaker;
      case 'burger maker':
        return ServiceAs.burgerMaker;
      case 'shawarma maker':
        return ServiceAs.shawarmaMaker;
      case 'chef':
        return ServiceAs.chef;
      case 'catering':
        return ServiceAs.cateringBusiness;
      case 'buffet':
        return ServiceAs.buffet;
      case 'live cooking':
        return ServiceAs.liveCooking;
      case 'outdoor cafe kiosk':
        return ServiceAs.outdoorCafeKiosk;
      case 'coffee hospitality service':
        return ServiceAs.coffeeHospitalityService;
      case 'decoration':
        return ServiceAs.decoration;
      case 'villas':
        return ServiceAs.villas;
      case 'farms':
        return ServiceAs.farms;
      case 'lands':
        return ServiceAs.lands;
      case 'furniture':
        return ServiceAs.furniture;
      case 'fitness trainer':
        return ServiceAs.fitnessTrainer;
      default:
        return null;
    }
  }

  @override
  void onInit() {
    super.onInit();
    // Initialize primary availability card
    primaryAvailabilityCard = AvailabilityCardModel(id: 'primary');
    // Do NOT create default package - let user add packages explicitly
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
    selectedServiceAsItems.clear();
    // Reset EventVenue when category changes
    selectedEventVenue.value = null;
    selectedEventVenueItems.clear();
    // Reset subOptions when category changes
    selectedSubOptions.clear();
    // Note: Role is no longer auto-changed - all roles available for all categories
    if (_categoryFromServiceType(selectedServiceType.value) == category) {
      return;
    }
    selectedServiceType.value = _defaultTypeForCategory(category);
  }

  /// Toggle a sub-option selection
  void toggleSubOption(ServiceSubOption option) {
    toggleSubOptionItem(option);
  }

  Future<bool> saveService({
    bool isEdit = false,
    ServiceModel? existingService,
  }) async {
    isLoading.value = true;

    try {
      // Validate required fields
      if (titleController.text.trim().isEmpty) {
        Get.snackbar('Error', 'Title is required');
        isLoading.value = false;
        return false;
      }
      if (descriptionController.text.trim().isEmpty) {
        Get.snackbar('Error', 'Description is required');
        isLoading.value = false;
        return false;
      }

      // Validate at least one availability has days selected
      final hasPrimaryAvailability = primaryAvailabilityCard.selectedDays.isNotEmpty;
      final hasAdditionalAvailability = additionalAvailabilityCards.any((card) => card.selectedDays.isNotEmpty);
      
      if (!hasPrimaryAvailability && !hasAdditionalAvailability) {
        Get.snackbar(
          'Required',
          'Please select at least one day for availability',
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red,
        );
        isLoading.value = false;
        return false;
      }

      // TODO: Move repeated validation logic into form validator mixin when we modularize this flow further.
      
      // Get all field values early for validation and conditional logic
      // Use serviceTypeName string to determine allowed fields - more reliable than category enum
      final serviceTypeName = _getServiceTypeName(selectedServiceType.value);
      final roleName = _getRoleName(selectedRole.value);
      final serviceAsValue = selectedServiceAs.value;
      
      // Determine if this is an Event-type service based on service type name
      final isEventType = serviceTypeName == 'Event';
      
      // Get service as name if selected
      String? serviceAsName;
      if (selectedServiceAsItems.isNotEmpty) {
        final item = selectedServiceAsItems.first;
        if (item is ServiceAs) {
          serviceAsName = item.label;
        } else if (item is String) {
          serviceAsName = item;
        }
      }

      // Attendance capacity - only for Event and Trainer categories
      int? attendanceValue;
      if (showAttendanceCapacity) {
        final attendanceText = attendanceCapacityController.text.trim();
        if (attendanceText.isNotEmpty) {
          attendanceValue = int.tryParse(attendanceText);
          if (attendanceValue == null || attendanceValue <= 0) {
            Get.snackbar(
              'Invalid Input',
              'Attendance capacity must be a positive number',
              backgroundColor: Colors.red.withOpacity(0.1),
              colorText: Colors.red,
            );
            isLoading.value = false;
            return false;
          }
        }
      }
      
      // Backend validation: attendance_capacity only for Event type
      if (!isEventType && serviceTypeName != 'Professional Trainer') {
        attendanceValue = null; // Don't send attendance for Hospitality
      }

      // Event venue - only for Event category
      String? eventVenue;
      if (showEventVenueDropdown && selectedEventVenueItems.isNotEmpty) {
        final item = selectedEventVenueItems.first;
        if (item is EventVenue) {
          eventVenue = item.label;
        } else if (item is String) {
          eventVenue = item;
        }
      }

      // Backend validation: event_vanue only for Event type
      if (!isEventType) {
        eventVenue = null;
      }

      // Sub options - only for Event + Business + specific ServiceAs
      String? options;
      if (showSubOptionsChecklist && selectedSubOptionsItems.isNotEmpty) {
        options = _getSubOptionLabel(selectedSubOptionsItems.first);
      }
      
      // Backend validation: options only for Event type
      if (!isEventType) {
        options = null;
      }

      // Validate Primary Availability Times
      if (primaryAvailabilityCard.selectedDays.isNotEmpty) {
        final start = primaryAvailabilityCard.startTime.value ??
            const TimeOfDay(hour: 9, minute: 0);
        final end = primaryAvailabilityCard.endTime.value ??
            const TimeOfDay(hour: 17, minute: 0);

        if (!_isValidTimeRange(start, end)) {
          Get.snackbar(
            'Invalid Time',
            'Start time must be before end time for primary availability',
            backgroundColor: Colors.red.withOpacity(0.1),
            colorText: Colors.red,
          );
          isLoading.value = false;
          return false;
        }
      }

      // Validate Additional Availability Times
      for (var i = 0; i < additionalAvailabilityCards.length; i++) {
        final card = additionalAvailabilityCards[i];
        if (card.selectedDays.isNotEmpty) {
          final start =
              card.startTime.value ?? const TimeOfDay(hour: 9, minute: 0);
          final end =
              card.endTime.value ?? const TimeOfDay(hour: 17, minute: 0);

          if (!_isValidTimeRange(start, end)) {
            Get.snackbar(
              'Invalid Time',
              'Start time must be before end time for additional availability #${i + 1}',
              backgroundColor: Colors.red.withOpacity(0.1),
              colorText: Colors.red,
            );
            isLoading.value = false;
            return false;
          }
        }
      }
      // Build packages for API
      final apiPackages = packages.asMap().entries.map((entry) {
        final index = entry.key;
        final p = entry.value;
        return PackageRequestModel(
          name: p.nameController.text.trim(),
          price: p.priceController.text.trim(),
          features: p.features.where((f) => f.isNotEmpty).toList(),
          sortOrder: index + 1,
        );
      }).toList();

      // Build availabilities for API (combine primary + additional)
      final apiAvailabilities = <AvailabilityRequestModel>[];

      // Primary availability
      if (primaryAvailabilityCard.selectedDays.isNotEmpty) {
        apiAvailabilities.add(
          AvailabilityRequestModel(
            id: null,
            weekDays: _mapDayNames(primaryAvailabilityCard.selectedDays),
            startTime: _formatTimeOfDayForApi(
              primaryAvailabilityCard.startTime.value,
              isEndTime: false,
            ),
            endTime: _formatTimeOfDayForApi(
              primaryAvailabilityCard.endTime.value,
              isEndTime: true,
            ),
            address: primaryAvailabilityCard.addressController.text.trim(),
            latitude: primaryAvailabilityCard.latitude.value,
            longitude: primaryAvailabilityCard.longitude.value,
            sortOrder: 1,
          ),
        );
      }

      // Additional availabilities
      for (var i = 0; i < additionalAvailabilityCards.length; i++) {
        final card = additionalAvailabilityCards[i];
        if (card.selectedDays.isNotEmpty) {
          apiAvailabilities.add(
            AvailabilityRequestModel(
              id: null,
              weekDays: _mapDayNames(card.selectedDays),
              startTime: _formatTimeOfDayForApi(
                card.startTime.value,
                isEndTime: false,
              ),
              endTime: _formatTimeOfDayForApi(
                card.endTime.value,
                isEndTime: true,
              ),
              address: card.addressController.text.trim(),
              latitude: card.latitude.value,
              longitude: card.longitude.value,
              sortOrder: i + 2,
            ),
          );
        }
      }

      // Get role name for API (already computed above)
      // roleName is already available from line 688

      // Get service as name if selected (already computed above)
      // serviceAsName is already available from line 699

      // Check for changes in edit mode
      if (isEdit && existingService != null) {
        final hasChanges = _hasServiceChanges(
          existingService: existingService,
          newTitle: titleController.text.trim(),
          newDescription: descriptionController.text.trim(),
          newServiceTypeName: serviceTypeName,
          newRoleName: roleName,
          newServiceAsName: serviceAsName,
          newEventVenue: eventVenue, // Use pre-computed filtered value
          newOptions: options, // Use pre-computed filtered value
          newAttendanceCapacity: attendanceValue,
          newCanGoOutsideLocation: primaryAvailabilityCard.canGoOutside.value,
          newCannotGoOutsideLocation: primaryAvailabilityCard.cannotGoOutside.value,
          newRequiresConfirmation: needsConfirmationBeforePayment.value,
          newImagePath: selectedImagePath.value,
        );

        if (!hasChanges) {
          Get.snackbar(
            'No Changes',
            'No changes detected to update',
            backgroundColor: Colors.orange.withOpacity(0.1),
            colorText: Colors.orange,
          );
          isLoading.value = false;
          return false;
        }
      }

      // Build the request model
      // Use pre-computed values that have been filtered based on category/role
      final request = ServiceRequestModel(
        id: existingService != null ? int.tryParse(existingService.id) : null,
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        serviceTypeName: serviceTypeName,
        roleName: roleName,
        serviceAsName: serviceAsName,
        eventVenue: eventVenue, // Already filtered by category above
        options: options, // Already filtered by category above
        attendanceCapacity: attendanceValue, // Already filtered by category above
        packages: apiPackages,
        availabilities: apiAvailabilities,
        canGoOutsideLocation: primaryAvailabilityCard.canGoOutside.value,
        cannotGoOutsideLocation: primaryAvailabilityCard.cannotGoOutside.value,
        requiresConfirmation: needsConfirmationBeforePayment.value,
        currency: 'AED',
        coverImage: selectedImagePath.value,
      );

      // Call the API
      final repository = const ServiceRepository();
      ServiceModel savedService;

      Log.d('=======> saveService - Request being sent: serviceTypeName=${request.serviceTypeName}, eventVenue=${request.eventVenue}');

      if (isEdit && existingService != null) {
        savedService = await repository.updateService(request);
      } else {
        savedService = await repository.createService(request);
      }

      // Update the services list
      final spController = Get.find<SPServicesController>();
      // Convert ServiceModel to MyServiceModel for the list
      final myService = MyServiceModel(
        id: savedService.apiId,
        providerId: savedService.providerId,
        title: savedService.title,
        coverImage: savedService.coverImage,
        createdAt:
            '${savedService.createdAt.day}${_getDaySuffix(savedService.createdAt.day)} ${_getMonthShort(savedService.createdAt.month)} - ${_getWeekdayShort(savedService.createdAt.weekday)} - ${savedService.createdAt.hour > 12 ? savedService.createdAt.hour - 12 : (savedService.createdAt.hour == 0 ? 12 : savedService.createdAt.hour)}:${savedService.createdAt.minute.toString().padLeft(2, '0')} ${savedService.createdAt.hour >= 12 ? 'PM' : 'AM'}',
      );
      if (isEdit && existingService != null) {
        spController.updateService(myService);
      } else {
        spController.addService(myService);
      }

      isLoading.value = false;
      Get.back(result: true);
      Get.snackbar(
        'Success',
        isEdit ? 'Service updated successfully' : 'Service added successfully',
      );
      return true;
    } on ApiException catch (e) {
      isLoading.value = false;
      Log.e('=======> saveService - ApiException caught: ${e.message}');
      Get.snackbar('Error', e.message);
      return false;
    } catch (e) {
      isLoading.value = false;
      Log.e('=======> saveService - Exception caught: $e');
      Get.snackbar('Error', 'Failed to save service: $e');
      return false;
    }
  }

  /// Map day names from display format to API format
  List<String> _mapDayNames(List<String> days) {
    return days.map((day) {
      switch (day.toLowerCase()) {
        case 'mon':
        case 'monday':
          return 'Mon';
        case 'tue':
        case 'tuesday':
          return 'Tue';
        case 'wed':
        case 'wednesday':
          return 'Wed';
        case 'thu':
        case 'thursday':
          return 'Thu';
        case 'fri':
        case 'friday':
          return 'Fri';
        case 'sat':
        case 'saturday':
          return 'Sat';
        case 'sun':
        case 'sunday':
          return 'Sun';
        default:
          return day;
      }
    }).toList();
  }
/// Check if start time is before end time
bool _isValidTimeRange(TimeOfDay start, TimeOfDay end) {
  final startMinutes = start.hour * 60 + start.minute;
  final endMinutes = end.hour * 60 + end.minute;
  return startMinutes < endMinutes;
}

/// Format time for API (HH:MM:SS format)
  String _formatTimeForApi(String time) {
    if (time.isEmpty) return '09:00:00';
    // If already in correct format, return as is
    if (time.contains(':') && time.split(':').length == 3) {
      return time;
    }
    // Convert HH:MM to HH:MM:SS
    if (time.contains(':') && time.split(':').length == 2) {
      return '$time:00';
    }
    return time;
  }

  /// Format TimeOfDay for API (HH:MM:SS format)
  String _formatTimeOfDayForApi(TimeOfDay? time, {bool isEndTime = false}) {
    if (time == null) {
      // Default: start_time = 09:00:00, end_time = 17:00:00
      return isEndTime ? '17:00:00' : '09:00:00';
    }
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute:00';
  }

  /// Get service type name for API
  String _getServiceTypeName(ServiceType type) {
    switch (type) {
      case ServiceType.catering:
        return 'Hospitality';
      case ServiceType.filming:
        return 'Filming';
      case ServiceType.cleaning:
        return 'Cleaning';
      case ServiceType.photography:
        return 'Photography';
      case ServiceType.event:
        return 'Event';
      case ServiceType.training:
        return 'Professional Trainer';
    }
  }

  /// Get role name for API
  String _getRoleName(ProviderRole role) {
    switch (role) {
      case ProviderRole.freelancer:
        return 'Freelancer';
      case ProviderRole.business:
        return 'Business';
      case ProviderRole.productiveFamily:
        return 'Productive Family';
    }
  }

  /// Get sub-option label for API (converts enum or string to label)
  String _getSubOptionLabel(dynamic item) {
    if (item is ServiceSubOption) {
      return item.label;
    } else if (item is String) {
      return item;
    }
    return item.toString();
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    locationController.dispose();
    attendanceCapacityController.dispose();
    newEventVenueController.dispose();
    newServiceAsController.dispose();
    newSubOptionController.dispose();
    primaryAvailabilityCard.dispose();
    for (var card in additionalAvailabilityCards) {
      card.dispose();
    }
    // Dispose all package controllers
    for (var pkg in packages) {
      pkg.dispose();
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

  EventVenue? _eventVenueFromString(String? venue) {
    if (venue == null) return null;
    switch (venue.toLowerCase()) {
      case 'hotel venues':
        return EventVenue.hotelVenues;
      case 'mall venues':
        return EventVenue.mallVenues;
      case 'restaurant venues':
        return EventVenue.restaurantVenues;
      case 'event halls':
        return EventVenue.eventHalls;
      default:
        return null;
    }
  }

  /// Get day suffix for date formatting (1st, 2nd, 3rd, etc.)
  String _getDaySuffix(int day) {
    if (day >= 11 && day <= 13) return 'th';
    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  /// Get short month name
  String _getMonthShort(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  /// Get short weekday name
  String _getWeekdayShort(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  bool _hasServiceChanges({
    required ServiceModel existingService,
    required String newTitle,
    required String newDescription,
    required String newServiceTypeName,
    required String newRoleName,
    String? newServiceAsName,
    String? newEventVenue,
    String? newOptions,
    int? newAttendanceCapacity,
    required bool newCanGoOutsideLocation,
    required bool newCannotGoOutsideLocation,
    required bool newRequiresConfirmation,
    String? newImagePath,
  }) {
    return newTitle != existingService.title ||
        newDescription != existingService.description ||
        newServiceTypeName != existingService.serviceTypeName ||
        newRoleName != existingService.roleName ||
        newServiceAsName != existingService.serviceAsName ||
        newEventVenue != existingService.eventVenue ||
        newOptions != existingService.options ||
        newAttendanceCapacity != existingService.attendanceCapacity ||
        newCanGoOutsideLocation != existingService.canGoOutsideLocation ||
        newCannotGoOutsideLocation != existingService.canNotGoOutsideLocation ||
        newRequiresConfirmation != existingService.requiresConfirmation ||
        (newImagePath != null &&
            newImagePath.isNotEmpty &&
            !newImagePath.startsWith('/media/') &&
            !newImagePath.startsWith('http'));
  }
}

/// Form data class for packages with proper controller management
/// Uses TextEditingControllers for features to maintain text field state
/// Also maintains reactive name and price for UI updates
class PackageFormData {
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final featureControllers = <TextEditingController>[].obs;

  // Reactive properties for UI updates when returning from packages view
  final name = ''.obs;
  final price = ''.obs;

  PackageFormData(); // No default empty feature - user adds explicitly

  /// Add a new feature controller
  void addFeature([String initialValue = '']) {
    featureControllers.add(TextEditingController(text: initialValue));
  }

  /// Remove a feature controller at the given index
  void removeFeature(int index) {
    if (index >= 0 && index < featureControllers.length) {
      featureControllers[index].dispose();
      featureControllers.removeAt(index);
    }
  }

  /// Sync controllers to reactive properties (call before returning from packages view)
  void syncToReactive() {
    name.value = nameController.text;
    price.value = priceController.text;
  }

  /// Get feature values as strings (only non-empty values)
  List<String> get features => featureControllers
      .map((c) => c.text.trim())
      .where((f) => f.isNotEmpty)
      .toList();

  /// Dispose all controllers
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    for (var controller in featureControllers) {
      controller.dispose();
    }
  }
}
