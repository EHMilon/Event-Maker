import 'package:event_maker/app_routes.dart';
import 'package:event_maker/models/service_model.dart';
import 'package:event_maker/services/customer_booking_repository.dart';
import 'package:event_maker/services/api_exception.dart';
import 'package:get/get.dart';

/// Controller for the customer booking flow.
/// Handles the complete booking process including:
/// - Sending booking requests
/// - Routing based on requires_confirmation
class ServiceBookingController extends GetxController {
  final CustomerBookingRepository _repository = CustomerBookingRepository();

  // Loading states
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // Booking data passed from previous screens
  ServiceModel? service;
  ServicePackage? selectedPackage;
  String? selectedDate;
  String? selectedTime;
  int? selectedDurationIndex;
  String? selectedLocation;
  String? latitude;
  String? longitude;
  String? specialRequest;

  // Result from API
  int? createdBookingId;
  bool? bookingRequiresConfirmation;
  bool? bookingCanPayNow;

  @override
  void onInit() {
    super.onInit();
    _loadArguments();
  }

  void _loadArguments() {
    final args = Get.arguments;
    if (args is Map) {
      service = args['service'] as ServiceModel?;
      selectedPackage = args['package'] as ServicePackage?;
      selectedDate = args['date'] as String?;
      selectedTime = args['time'] as String?;
      selectedDurationIndex = args['duration_index'] as int?;
      selectedLocation = args['location'] as String?;
      latitude = args['latitude'] as String?;
      longitude = args['longitude'] as String?;
    }
  }

  /// Set special request from the request screen
  void setSpecialRequest(String request) {
    specialRequest = request.isEmpty ? null : request;
  }

  /// Submit the booking request.
  /// Returns true if successful, false otherwise.
  Future<bool> submitBooking() async {
    if (service == null || selectedPackage == null) {
      errorMessage.value = 'Service or package not selected';
      return false;
    }

    if (selectedDate == null || selectedTime == null) {
      errorMessage.value = 'Date or time not selected';
      return false;
    }

    if (selectedLocation == null) {
      errorMessage.value = 'Location not selected';
      return false;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Format start time (convert 12h to 24h format for API)
      final formattedTime = _formatTimeForApi(selectedTime!);

      // Get duration in hours
      final durationHours = _getDurationInHours();

      // Call the API
      final response = await _repository.sendBookingRequest(
        serviceId: int.parse(service!.id),
        selectedPackageId: selectedPackage!.id,
        bookingDate: selectedDate!,
        startTime: formattedTime,
        servicesDuration: durationHours,
        specialRequest: specialRequest,
        location: selectedLocation!,
        latitude: latitude ?? '0.0',
        longitude: longitude ?? '0.0',
      );

      // Store result
      createdBookingId = response.data.id;
      bookingRequiresConfirmation = response.data.requiresConfirmation;
      bookingCanPayNow = response.data.canPayNow;

      isLoading.value = false;
      return true;
    } on ApiException catch (e) {
      errorMessage.value = e.message;
      isLoading.value = false;
      return false;
    } catch (e) {
      errorMessage.value = 'Failed to submit booking: $e';
      isLoading.value = false;
      return false;
    }
  }

  /// Navigate to the appropriate next screen after booking submission.
  /// Based on requires_confirmation:
  /// - If false (direct booking): Go to payment screen
  /// - If true (needs confirmation): Go to booking request sent screen
  Future<void> navigateToNextScreen() async {
    final success = await submitBooking();
    if (!success) return;

    // Check if confirmation is required
    if (bookingRequiresConfirmation == true && bookingCanPayNow == false) {
      // Go to booking request sent screen - wait for SP approval
      Get.offNamed(AppRoutes.bookingRequestSent);
    } else {
      // Direct booking - go to payment
      // Pass booking details for payment
      Get.toNamed(
        AppRoutes.payment,
        arguments: {
          'service': service,
          'package': selectedPackage,
          'booking_id': createdBookingId,
          'booking_date': selectedDate,
          'booking_time': selectedTime,
          'location': selectedLocation,
        },
      );
    }
  }

  /// Format time for API (12h to 24h format)
  String _formatTimeForApi(String time) {
    // Input: "10:00 AM" or "2:00 PM"
    // Output: "10:00:00" or "14:00:00"
    try {
      final parts = time.split(' ');
      final timeParts = parts[0].split(':');
      var hours = int.parse(timeParts[0]);
      final minutes = timeParts.length > 1 ? timeParts[1] : '00';
      final isPM = parts.length > 1 && parts[1].toUpperCase() == 'PM';

      if (isPM && hours != 12) {
        hours += 12;
      } else if (!isPM && hours == 12) {
        hours = 0;
      }

      return '${hours.toString().padLeft(2, '0')}:$minutes:00';
    } catch (e) {
      // Default fallback
      return '10:00:00';
    }
  }

  /// Get duration in hours from selected duration index
  int _getDurationInHours() {
    if (selectedDurationIndex == null) return 1;
    // Array: ['1 Hour', '2 Hours', '3 Hours', '4 Hours', '5 Hours', '6 Hours', 'Full Day']
    return selectedDurationIndex! + 1;
  }
}
