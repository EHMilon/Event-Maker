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
import '../../../widgets/add_custom_service_dialog.dart';

enum ServiceCategory { hospitality, event, trainer }

enum ProviderRole { freelancer, business, productiveFamily }

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
  final selectedEventVenueItems =
      <dynamic>[].obs; // Can hold EventVenue enum or String

  /// Controller for the new Event Venue text input
  final newEventVenueController = TextEditingController();

  /// Toggle for showing/hiding the add Event Venue text field
  var showAddEventVenueField = false.obs;

  final selectedSubOptions = <ServiceSubOption>[].obs;
  final selectedSubOptionsItems =
      <dynamic>[].obs; // Can hold ServiceSubOption enum or String

  final selectedSubServiceItems = <dynamic>[].obs;
  final selectedSubSubServiceItems = <dynamic>[].obs;

  // Nested dropdown data from backend
  var nestedDropdownData = <CategoryServiceType>[].obs;
  var isLoadingDropdowns = false.obs;

  // Options lists (populated from nestedDropdownData based on category/role)
  var backendServiceAsOptions = <String>[].obs;
  var subOptions = <String>[].obs;
  var backendSubSubServiceOptions = <String>[].obs;

  // Selected string values (from backend)
  final selectedServiceAsString = Rxn<String>();
  final selectedSubServiceString = Rxn<String>();
  final selectedSubSubServiceString = Rxn<String>();

  /// Refresh options from nested data based on current category/role
  void _refreshOptionsFromNestedData() {
    final serviceTypeName = _getServiceTypeNameForApi(selectedCategory.value);
    final roleName = _getRoleNameForApi(selectedRole.value);

    backendServiceAsOptions.clear();
    subOptions.clear();
    backendSubSubServiceOptions.clear();

    for (var serviceType in nestedDropdownData) {
      if (serviceType.serviceTypeName == serviceTypeName) {
        for (var role in serviceType.roles) {
          if (role.roleName == roleName) {
            backendServiceAsOptions.value = role.serviceAsNames
                .map((e) => e.serviceAsName)
                .toList();
            return;
          }
        }
      }
    }
  }

  /// Refresh sub options when service_as is selected
  void _refreshSubOptionsFromNestedData() {
    subOptions.clear();
    backendSubSubServiceOptions.clear();

    if (selectedServiceAsString.value == null) return;

    final serviceTypeName = _getServiceTypeNameForApi(selectedCategory.value);
    final roleName = _getRoleNameForApi(selectedRole.value);

    for (var serviceType in nestedDropdownData) {
      if (serviceType.serviceTypeName == serviceTypeName) {
        for (var role in serviceType.roles) {
          if (role.roleName == roleName) {
            for (var serviceAs in role.serviceAsNames) {
              if (serviceAs.serviceAsName == selectedServiceAsString.value) {
                subOptions.value = serviceAs.subServices
                    .map((e) => e.subServiceName)
                    .toList();
                return;
              }
            }
          }
        }
      }
    }
  }

  /// Refresh sub-sub options when sub_service is selected
  void _refreshSubSubOptionsFromNestedData() {
    backendSubSubServiceOptions.clear();

    if (selectedSubServiceString.value == null) return;

    final serviceTypeName = _getServiceTypeNameForApi(selectedCategory.value);
    final roleName = _getRoleNameForApi(selectedRole.value);

    for (var serviceType in nestedDropdownData) {
      if (serviceType.serviceTypeName == serviceTypeName) {
        for (var role in serviceType.roles) {
          if (role.roleName == roleName) {
            for (var serviceAs in role.serviceAsNames) {
              if (serviceAs.serviceAsName == selectedServiceAsString.value) {
                for (var subService in serviceAs.subServices) {
                  if (subService.subServiceName ==
                      selectedSubServiceString.value) {
                    backendSubSubServiceOptions.value =
                        subService.subSubServices;
                    return;
                  }
                }
              }
            }
          }
        }
      }
    }
  }

  /// Returns available ServiceAs options based on current selected role and category
  /// Now populated from backend nested dropdown data
  List<String> get availableServiceAsOptions {
    if (nestedDropdownData.isEmpty) return [];

    final serviceTypeName = _getServiceTypeNameForApi(selectedCategory.value);
    final roleName = _getRoleNameForApi(selectedRole.value);

    for (var serviceType in nestedDropdownData) {
      if (serviceType.serviceTypeName == serviceTypeName) {
        for (var role in serviceType.roles) {
          if (role.roleName == roleName) {
            return role.serviceAsNames.map((e) => e.serviceAsName).toList();
          }
        }
      }
    }
    return [];
  }

  /// Returns available sub-service options based on selected ServiceAs
  List<String> get availableSubOptions {
    if (selectedServiceAsString.value == null || nestedDropdownData.isEmpty) {
      return [];
    }

    final serviceTypeName = _getServiceTypeNameForApi(selectedCategory.value);
    final roleName = _getRoleNameForApi(selectedRole.value);

    for (var serviceType in nestedDropdownData) {
      if (serviceType.serviceTypeName == serviceTypeName) {
        for (var role in serviceType.roles) {
          if (role.roleName == roleName) {
            for (var serviceAs in role.serviceAsNames) {
              if (serviceAs.serviceAsName == selectedServiceAsString.value) {
                return serviceAs.subServices
                    .map((e) => e.subServiceName)
                    .toList();
              }
            }
          }
        }
      }
    }
    return [];
  }

  /// Returns available sub-sub-service options based on selected SubService
  List<String> get availableSubSubOptions {
    if (selectedSubServiceString.value == null || nestedDropdownData.isEmpty) {
      return [];
    }

    final serviceTypeName = _getServiceTypeNameForApi(selectedCategory.value);
    final roleName = _getRoleNameForApi(selectedRole.value);

    for (var serviceType in nestedDropdownData) {
      if (serviceType.serviceTypeName == serviceTypeName) {
        for (var role in serviceType.roles) {
          if (role.roleName == roleName) {
            for (var serviceAs in role.serviceAsNames) {
              if (serviceAs.serviceAsName == selectedServiceAsString.value) {
                for (var subService in serviceAs.subServices) {
                  if (subService.subServiceName ==
                      selectedSubServiceString.value) {
                    return subService.subSubServices;
                  }
                }
              }
            }
          }
        }
      }
    }
    return [];
  }

  /// Returns true if sub-options checklist should be shown (Event + Business + Buffet/LiveCooking/OutdoorCafeKiosk)
  bool get showSubOptionsChecklist =>
      selectedCategory.value == ServiceCategory.event &&
      selectedRole.value == ProviderRole.business &&
      (selectedServiceAsString.value == 'Buffet' ||
          selectedServiceAsString.value == 'Live Cooking' ||
          selectedServiceAsString.value == 'Outdoor Cafe Kiosk');

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

  /// Show popup to add custom Service As
  void addCustomServiceAsDirectly() {
    AddCustomServiceDialog.show(
      context: Get.context!,
      title: 'Add Custom Service As',
      hintText: 'Enter custom service as (e.g., Chef, Pastry)',
      onSave: (value) async {
        try {
          // Call API to create category master
          final response = await const ServiceRepository().createCategoryMaster(
            serviceTypeName: _getServiceTypeNameForApi(selectedCategory.value),
            roleName: _getRoleNameForApi(selectedRole.value),
            serviceAsName: value,
            sortOrder: 1,
          );

          if (response.success) {
            // Add to options list and select it
            backendServiceAsOptions.add(value);
            _refreshSubOptionsFromNestedData();

            selectedServiceAsItems.clear();
            selectedServiceAsItems.add(value);
            selectedServiceAsString.value = value;

            Get.snackbar('Success', 'Custom service added successfully');
          }
        } catch (e) {
          Log.e('=======> addCustomServiceAsDirectly - Error: $e');
          Get.snackbar('Error', 'Failed to add custom service: $e');
        }
      },
    );
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
      // Deselecting - clear everything
      selectedServiceAsItems.remove(item);
      selectedServiceAsString.value = null;
      // Clear downstream selections when Service As is deselected
      selectedSubServiceItems.clear();
      selectedSubServiceString.value = null;
      selectedSubSubServiceItems.clear();
      selectedSubSubServiceString.value = null;
      subOptions.clear();
      backendSubSubServiceOptions.clear();
    } else {
      // Selecting new Service As - clear previous selections first
      selectedServiceAsItems.clear(); // Enforce single selection
      selectedServiceAsItems.add(item);

      // Clear all downstream selections when Service As changes
      selectedSubServiceItems.clear();
      selectedSubServiceString.value = null;
      selectedSubSubServiceItems.clear();
      selectedSubSubServiceString.value = null;
      subOptions.clear();
      backendSubSubServiceOptions.clear();

      if (item is String) {
        selectedServiceAsString.value = item;
      }
      // Refresh sub options from nested data
      _refreshSubOptionsFromNestedData();
    }
  }

  /// Remove a Service As from the selection
  void removeServiceAs(dynamic item) {
    selectedServiceAsItems.remove(item);
  }

  /// Show popup to add custom Sub Service (Level 2)
  void addCustomSubOptionDirectly() {
    // Need Level 1 selected first
    if (selectedServiceAsString.value == null ||
        selectedServiceAsString.value!.isEmpty) {
      Get.snackbar('Error', 'Please select Service As first');
      return;
    }

    AddCustomServiceDialog.show(
      context: Get.context!,
      title: 'Add Custom Sub Service',
      hintText: 'Enter custom sub service (e.g., Buffet, Live Cooking)',
      onSave: (value) async {
        try {
          // Call API to create category master with sub_service_name
          final response = await const ServiceRepository().createCategoryMaster(
            serviceTypeName: _getServiceTypeNameForApi(selectedCategory.value),
            roleName: _getRoleNameForApi(selectedRole.value),
            serviceAsName: selectedServiceAsString.value!,
            subServiceName: value,
            sortOrder: 1,
          );

          if (response.success) {
            // Add to sub options list and select it
            subOptions.add(value);
            _refreshSubSubOptionsFromNestedData();

            selectedSubServiceItems.clear();
            selectedSubServiceItems.add(value);
            selectedSubServiceString.value = value;

            Get.snackbar('Success', 'Custom sub service added successfully');
          }
        } catch (e) {
          Log.e('=======> addCustomSubOptionDirectly - Error: $e');
          Get.snackbar('Error', 'Failed to add custom sub service: $e');
        }
      },
    );
  }

  /// Show popup to add custom Sub Service (Level 3)
  void addCustomSubSubOptionDirectly() {
    // Need Level 1 and Level 2 selected first
    if (selectedServiceAsString.value == null ||
        selectedServiceAsString.value!.isEmpty) {
      Get.snackbar('Error', 'Please select Service As first');
      return;
    }
    if (selectedSubServiceString.value == null ||
        selectedSubServiceString.value!.isEmpty) {
      Get.snackbar('Error', 'Please select Sub Service first');
      return;
    }

    AddCustomServiceDialog.show(
      context: Get.context!,
      title: 'Add Custom Sub Service',
      hintText: 'Enter custom sub sub service (e.g., Indian Buffet)',
      onSave: (value) async {
        try {
          // Call API to create category master with sub_sub_service_name
          final response = await const ServiceRepository().createCategoryMaster(
            serviceTypeName: _getServiceTypeNameForApi(selectedCategory.value),
            roleName: _getRoleNameForApi(selectedRole.value),
            serviceAsName: selectedServiceAsString.value!,
            subServiceName: selectedSubServiceString.value!,
            subSubServiceName: value,
            sortOrder: 1,
          );

          if (response.success) {
            // Add to dropdown options and select it
            backendSubSubServiceOptions.add(value);
            selectedSubSubServiceItems.clear();
            selectedSubSubServiceItems.add(value);
            selectedSubSubServiceString.value = value;

            Get.snackbar(
              'Success',
              'Custom sub sub service added successfully',
            );
          }
        } catch (e) {
          Log.e('=======> addCustomSubSubOptionDirectly - Error: $e');
          Get.snackbar('Error', 'Failed to add custom sub sub service: $e');
        }
      },
    );
  }

  /// Close/hide the add Sub Option text field
  void closeAddSubOptionField() {
    showAddSubOptionField.value = false;
    newSubOptionController.clear();
  }

  /// Add a new custom Sub Option to the selection (legacy method)
  void addCustomSubOption() {
    final value = newSubOptionController.text.trim();
    if (value.isNotEmpty) {
      selectedSubOptionsItems.clear(); // Enforce single selection
      selectedSubOptionsItems.add(value);
      newSubOptionController.clear();
      showAddSubOptionField.value = false;
    }
  }

  /// Toggle Level 2 Sub Service selection
  void toggleSubService(String item) {
    if (selectedSubServiceItems.contains(item)) {
      selectedSubServiceItems.remove(item);
      selectedSubServiceString.value = null;
      subOptions.clear();
    } else {
      selectedSubServiceItems.clear();
      selectedSubServiceItems.add(item);
      selectedSubServiceString.value = item;

      // Clear Level 3
      selectedSubSubServiceItems.clear();
      selectedSubSubServiceString.value = null;
      backendSubSubServiceOptions.clear();

      // Refresh sub-sub options from nested data
      _refreshSubSubOptionsFromNestedData();
    }
  }

  /// Toggle Level 3 Sub Sub Service selection
  void toggleSubSubService(String item) {
    if (selectedSubSubServiceItems.contains(item)) {
      selectedSubSubServiceItems.remove(item);
      selectedSubSubServiceString.value = null;
    } else {
      selectedSubSubServiceItems.clear();
      selectedSubSubServiceItems.add(item);
      selectedSubSubServiceString.value = item;
    }
  }

  /// Toggle SubOption selection
  void toggleSubOptionItem(dynamic item) {
    if (selectedSubOptionsItems.contains(item)) {
      selectedSubOptionsItems.remove(item);
      if (item is String) {
        if (selectedSubSubServiceString.value == item) {
          selectedSubSubServiceString.value = null;
        }
      }
      if (item is ServiceSubOption) {
        selectedSubOptions.remove(item);
      }
    } else {
      selectedSubOptionsItems.clear(); // Enforce single selection
      selectedSubOptions.clear();
      selectedSubOptionsItems.add(item);
      if (item is String) {
        selectedSubSubServiceString.value = item;
      }
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
    // Clear any existing data first to ensure clean state
    _clearAllServiceFields();

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

    // ServiceAs (Level 1) - use string from serviceAsName
    if (service.serviceAsName.isNotEmpty) {
      selectedServiceAsItems.clear();
      selectedServiceAsItems.add(service.serviceAsName);
      selectedServiceAsString.value = service.serviceAsName;

      // Ensure the selected value is in the options list
      if (!backendServiceAsOptions.contains(service.serviceAsName)) {
        backendServiceAsOptions.add(service.serviceAsName);
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

    // Level 2 (Sub Service) - Use subServiceName from API
    if (service.subServiceName != null && service.subServiceName!.isNotEmpty) {
      selectedSubServiceItems.clear();
      selectedSubServiceItems.add(service.subServiceName);
      selectedSubServiceString.value = service.subServiceName;

      // Update subOptions list to include this item so it's visible in dropdown
      if (!subOptions.contains(service.subServiceName)) {
        subOptions.add(service.subServiceName!);
      }
    }

    // Level 3 (Sub Sub Service) - Use subSubServiceName from API
    if (service.subSubServiceName != null &&
        service.subSubServiceName!.isNotEmpty) {
      selectedSubSubServiceItems.clear();
      selectedSubSubServiceItems.add(service.subSubServiceName);
      selectedSubSubServiceString.value = service.subSubServiceName;

      // Update backendSubSubServiceOptions list to include this item
      if (!backendSubSubServiceOptions.contains(service.subSubServiceName)) {
        backendSubSubServiceOptions.add(service.subSubServiceName!);
      }
    }

    // Legacy: Options field (for backward compatibility)
    if (service.options != null && service.options!.isNotEmpty) {
      // Only use if subServiceName is not already set
      if (selectedSubServiceString.value == null ||
          selectedSubServiceString.value!.isEmpty) {
        selectedSubServiceItems.clear();
        // Handle comma separated options
        final optionsList = service.options!
            .split(',')
            .map((e) => e.trim())
            .toList();
        selectedSubServiceItems.addAll(optionsList);
        selectedSubServiceString.value = optionsList.join(', ');

        // Update subOptions list to include these items
        for (var opt in optionsList) {
          if (!subOptions.contains(opt)) {
            subOptions.add(opt);
          }
        }
      }
    }

    // Fetch dropdown options in sequence to ensure proper initialization
    // This ensures the dropdowns have the correct options available
    _fetchDropdownOptionsForEdit();

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

  /// Fetch dropdown options for edit mode to ensure selected values are available
  Future<void> _fetchDropdownOptionsForEdit() async {
    // Wait for nested dropdown data to load if not already loaded
    if (nestedDropdownData.isEmpty) {
      await fetchNestedDropdownData();
    }

    // Refresh Level 1 options based on current category/role
    _refreshOptionsFromNestedData();

    // Fetch Level 2 options if Level 1 is selected
    if (selectedServiceAsString.value != null) {
      _refreshSubOptionsFromNestedData();

      // Ensure selected Level 2 value is in the options list
      if (selectedSubServiceString.value != null &&
          !subOptions.contains(selectedSubServiceString.value)) {
        subOptions.add(selectedSubServiceString.value!);
      }
    }

    // Fetch Level 3 options if Level 2 is selected
    if (selectedSubServiceString.value != null) {
      _refreshSubSubOptionsFromNestedData();

      // Ensure selected Level 3 value is in the options list
      if (selectedSubSubServiceString.value != null &&
          !backendSubSubServiceOptions.contains(
            selectedSubSubServiceString.value,
          )) {
        backendSubSubServiceOptions.add(selectedSubSubServiceString.value!);
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

    // Initial fetch of nested dropdown data
    fetchNestedDropdownData().then((_) {
      // Refresh options after data is loaded to ensure default selections are reflected in options
      _refreshOptionsFromNestedData();
    });
  }

  /// Fetch all nested dropdown data from backend in a single call
  Future<void> fetchNestedDropdownData() async {
    isLoadingDropdowns.value = true;
    try {
      final response = await const ServiceRepository()
          .fetchCategoryMasterNestedDropdown();

      if (response.success) {
        nestedDropdownData.value = response.data;
        Log.d(
          '=======> fetchNestedDropdownData - loaded ${response.data.length} service types',
        );
      }
    } on ApiException catch (e) {
      Log.e('=======> fetchNestedDropdownData - ApiException: ${e.message}');
    } catch (e) {
      Log.e('=======> fetchNestedDropdownData - Error: $e');
    } finally {
      isLoadingDropdowns.value = false;
    }
  }

  /// Fetch dropdown options from backend based on current selections
  /// Now using local filtering from nestedDropdownData
  /// Kept for backward compatibility - just refreshes the current options
  Future<void> fetchDropdownOptions({String? level}) async {
    // No longer needed - data is loaded once and filtered locally
    // This method is kept for backward compatibility
    return;
  }

  /// Fetch service_as_name options when category or role changes
  /// Now uses local data from nestedDropdownData
  void fetchServiceAsOptions() {
    // Clear downstream selections when category/role changes
    selectedServiceAsString.value = null;
    selectedSubServiceString.value = null;
    selectedSubSubServiceString.value = null;
    selectedServiceAsItems.clear();
    selectedSubServiceItems.clear();
    selectedSubSubServiceItems.clear();
    // Data is already in nestedDropdownData - UI will use availableServiceAsOptions
  }

  /// Fetch sub_service_name options when service_as is selected
  /// Now uses local data from nestedDropdownData
  void fetchSubServiceOptions() {
    // Clear downstream selections when ServiceAs changes
    selectedSubServiceString.value = null;
    selectedSubSubServiceString.value = null;
    selectedSubServiceItems.clear();
    selectedSubSubServiceItems.clear();
    // Data is already in nestedDropdownData - UI will use availableSubOptions
  }

  /// Fetch sub_sub_service_name options when sub_service is selected
  /// Now uses local data from nestedDropdownData
  void fetchSubSubServiceOptions() {
    // Clear Level 3 selections
    selectedSubSubServiceString.value = null;
    selectedSubSubServiceItems.clear();
    // Data is already in nestedDropdownData - UI will use availableSubSubOptions
  }

  String _getServiceTypeNameForApi(ServiceCategory category) {
    switch (category) {
      case ServiceCategory.hospitality:
        return 'Hospitality';
      case ServiceCategory.event:
        return 'Event';
      case ServiceCategory.trainer:
        return 'Professional Trainer';
    }
  }

  String _getRoleNameForApi(ProviderRole role) {
    switch (role) {
      case ProviderRole.freelancer:
        return 'Freelancer';
      case ProviderRole.business:
        return 'Business';
      case ProviderRole.productiveFamily:
        return 'Productive Family';
    }
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
    // Clear all service-related fields when category changes
    _clearAllServiceFields();
    // Update service type
    if (_categoryFromServiceType(selectedServiceType.value) != category) {
      selectedServiceType.value = _defaultTypeForCategory(category);
    }
    // Refresh options from nested data based on new category/role
    _refreshOptionsFromNestedData();
  }

  /// Clear all service-related fields when category/role changes
  /// This ensures no stale data is sent to the backend
  void _clearAllServiceFields() {
    // Clear Level 1 (Service As)
    selectedServiceAsItems.clear();
    selectedServiceAsString.value = null;

    // Clear Level 2 (Sub Service)
    selectedSubServiceItems.clear();
    selectedSubServiceString.value = null;

    // Clear Level 3 (Sub Sub Service)
    selectedSubSubServiceItems.clear();
    selectedSubSubServiceString.value = null;

    // Clear dropdown options
    backendServiceAsOptions.clear();
    subOptions.clear();
    backendSubSubServiceOptions.clear();

    // Clear Event Venue (only applicable for Event category)
    selectedEventVenue.value = null;
    selectedEventVenueItems.clear();

    // Clear other dependent fields
    selectedSubOptions.clear();
    selectedSubOptionsItems.clear();

    // Clear custom field states
    showAddServiceAsField.value = false;
    showAddSubOptionField.value = false;
    newServiceAsController.clear();
    newSubOptionController.clear();

    // Clear attendance capacity (only applicable for Event/Trainer categories)
    attendanceCapacityController.clear();
  }

  /// Update role and clear dependent fields
  void updateRole(ProviderRole role) {
    selectedRole.value = role;
    // Clear all service-related fields when role changes
    _clearAllServiceFields();
    // Refresh options from nested data based on new role
    _refreshOptionsFromNestedData();
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
      final hasPrimaryAvailability =
          primaryAvailabilityCard.selectedDays.isNotEmpty;
      final hasAdditionalAvailability = additionalAvailabilityCards.any(
        (card) => card.selectedDays.isNotEmpty,
      );

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
      final serviceTypeName = _getServiceTypeNameForApi(selectedCategory.value);
      final roleName = _getRoleNameForApi(selectedRole.value);

      // Determine if this is an Event-type service
      final isEventType = serviceTypeName == 'Event';
      final isTrainerType = serviceTypeName == 'Professional Trainer';

      // Attendance capacity - only for Event and Trainer categories
      int? attendanceValue;
      if (isEventType || isTrainerType) {
        final attendanceText = attendanceCapacityController.text.trim();
        if (attendanceText.isNotEmpty) {
          attendanceValue = int.tryParse(attendanceText);
        }
      }

      // Get service as name if selected
      String? serviceAsName = selectedServiceAsString.value;

      // Get sub service and sub-sub service names from hierarchical selections
      // Only include if service_as_name is selected (Level 1 must be selected for Level 2/3 to be valid)
      String? subServiceName = null; // Explicitly initialize to null
      String? subSubServiceName = null; // Explicitly initialize to null

      if (serviceAsName != null && serviceAsName.isNotEmpty) {
        // Only include sub_service_name if it matches the current service_as_name context
        subServiceName = selectedSubServiceString.value;
        subSubServiceName = selectedSubSubServiceString.value;
      } else {
        // Explicitly null when service_as_name is not selected
        subServiceName = null;
        subSubServiceName = null;
      }

      Log.d(
        '=======> saveService - DEBUG: serviceAsName=$serviceAsName, subServiceName=$subServiceName, subSubServiceName=$subSubServiceName',
      );

      // Event venue - only for Event category
      String? eventVenue;
      if (isEventType && selectedEventVenueItems.isNotEmpty) {
        final item = selectedEventVenueItems.first;
        if (item is EventVenue) {
          eventVenue = item.label;
        } else if (item is String) {
          eventVenue = item;
        }
      }

      // Options (level 2) - we send this as 'options' field in API
      String? options = subServiceName;

      Log.d(
        '=======> saveService - DEBUG: serviceAsName=$serviceAsName, subServiceName=$subServiceName, subSubServiceName=$subSubServiceName',
      );

      Log.d(
        '=======> saveService - Prepared data: serviceTypeName=$serviceTypeName, isEventType=$isEventType, attendance=$attendanceValue, options=$options',
      );

      // Validate Primary Availability Times
      if (primaryAvailabilityCard.selectedDays.isNotEmpty) {
        final start =
            primaryAvailabilityCard.startTime.value ??
            const TimeOfDay(hour: 9, minute: 0);
        final end =
            primaryAvailabilityCard.endTime.value ??
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
          newCannotGoOutsideLocation:
              primaryAvailabilityCard.cannotGoOutside.value,
          newRequiresConfirmation: needsConfirmationBeforePayment.value,
          newImagePath: selectedImagePath.value,
          newAvailabilities: apiAvailabilities,
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
        subServiceName: subServiceName,
        subSubServiceName: subSubServiceName,
        eventVenue: eventVenue, // Already filtered by category above
        options: options, // Already filtered by category above
        attendanceCapacity:
            attendanceValue, // Already filtered by category above
        packages: apiPackages,
        availabilities: apiAvailabilities,
        canGoOutsideLocation: primaryAvailabilityCard.canGoOutside.value,
        cannotGoOutsideLocation: primaryAvailabilityCard.cannotGoOutside.value,
        requiresConfirmation: needsConfirmationBeforePayment.value,
        currency: 'AED',
        coverImage: selectedImagePath.value,
      );

      // Debug: Log the multipart fields being sent
      final multipartFields = request.toMultipartFields();
      Log.d('=======> saveService - Multipart fields: $multipartFields');

      // Call the API
      final repository = const ServiceRepository();
      ServiceModel savedService;

      Log.d(
        '=======> saveService - Request being sent: serviceTypeName=${request.serviceTypeName}, serviceAsName=${request.serviceAsName}, subServiceName=${request.subServiceName}, subSubServiceName=${request.subSubServiceName}',
      );

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
        createdAt: _formatDateTime(
          isEdit && existingService != null
              ? existingService.createdAt
              : savedService.createdAt,
        ),
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

  /// Format DateTime to "13th Apr - Mon - 5:30 PM"
  String _formatDateTime(DateTime dateTime) {
    final day = dateTime.day;
    final suffix = _getDaySuffix(day);
    final month = _getMonthShort(dateTime.month);
    final weekday = _getWeekdayShort(dateTime.weekday);

    // Format time: "5:30 PM"
    int hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';

    if (hour > 12) hour -= 12;
    if (hour == 0) hour = 12;

    return '$day$suffix $month - $weekday - $hour:$minute $period';
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
    List<AvailabilityRequestModel>? newAvailabilities,
  }) {
    final basicChanges = newTitle != existingService.title ||
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

    if (basicChanges) return true;

    if (newAvailabilities == null) {
      return existingService.availabilities.isEmpty;
    }

    if (newAvailabilities.length != existingService.availabilities.length) {
      return true;
    }

    for (var i = 0; i < newAvailabilities.length; i++) {
      final newAvail = newAvailabilities[i];
      final existingAvail = existingService.availabilities[i];

      if (newAvail.weekDays.length != existingAvail.weekDays.length) {
        return true;
      }
      for (var j = 0; j < newAvail.weekDays.length; j++) {
        if (newAvail.weekDays[j] != existingAvail.weekDays[j]) {
          return true;
        }
      }
      if (newAvail.startTime != existingAvail.startTime ||
          newAvail.endTime != existingAvail.endTime ||
          newAvail.address != existingAvail.address) {
        return true;
      }
    }

    return false;
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
