import 'package:event_maker/models/booking_request_model.dart';
import 'package:event_maker/services/booking_request_repository.dart';
import 'package:event_maker/services/api_exception.dart';
import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class RequestsController extends GetxController {
  final BookingRequestRepository _repository = BookingRequestRepository();

  // Loading states
  final isLoading = false.obs;
  final isLoadingUpcoming = false.obs;
  final isLoadingPast = false.obs;

  // Error states
  final hasError = false.obs;
  final errorMessage = ''.obs;
  final upcomingError = ''.obs;
  final pastError = ''.obs;

  // Data
  final upcomingRequests = <BookingRequestModel>[].obs;
  final pastRequests = <BookingRequestModel>[].obs;

  // Tab selection
  final selectedTabIndex = 0.obs;

  // Booking detail cache
  final bookingDetails = <int, BookingRequestDetailModel>{}.obs;
  final isLoadingDetail = false.obs;
  final detailError = ''.obs;

  // Action loading states
  final isAccepting = false.obs;
  final isRejecting = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchRequests();
    ever(selectedTabIndex, _onTabChanged);
  }

  void _onTabChanged(int index) {
    if (index == 0 && upcomingRequests.isEmpty) {
      fetchUpcomingRequests();
    } else if (index == 1 && pastRequests.isEmpty) {
      fetchPastRequests();
    }
  }

  /// Fetch both upcoming and past requests
  Future<void> fetchRequests() async {
    // Check connectivity first
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      hasError.value = true;
      errorMessage.value = 'noInternet'.tr;
      return;
    }

    hasError.value = false;
    errorMessage.value = '';

    // Fetch both tabs in parallel
    await Future.wait([
      fetchUpcomingRequests(),
      fetchPastRequests(),
    ]);
  }

  /// Fetch upcoming booking requests
  Future<void> fetchUpcomingRequests() async {
    try {
      isLoadingUpcoming.value = true;
      upcomingError.value = '';

      final response = await _repository.fetchBookingRequests(tab: 'upcoming');

      if (response.success) {
        upcomingRequests.assignAll(response.data);
      } else {
        upcomingError.value = response.message;
      }
    } on ApiException catch (e) {
      upcomingError.value = e.message;
      Log.e('Upcoming requests error: ${e.message}');
    } catch (e) {
      upcomingError.value = 'serverError'.tr;
      Log.e('Upcoming requests error: $e');
    } finally {
      isLoadingUpcoming.value = false;
    }
  }

  /// Fetch past booking requests
  Future<void> fetchPastRequests() async {
    try {
      isLoadingPast.value = true;
      pastError.value = '';

      final response = await _repository.fetchBookingRequests(tab: 'past');

      if (response.success) {
        pastRequests.assignAll(response.data);
      } else {
        pastError.value = response.message;
      }
    } on ApiException catch (e) {
      pastError.value = e.message;
      Log.e('Past requests error: ${e.message}');
    } catch (e) {
      pastError.value = 'serverError'.tr;
      Log.e('Past requests error: $e');
    } finally {
      isLoadingPast.value = false;
    }
  }

  /// Fetch booking request detail
  Future<BookingRequestDetailModel?> fetchBookingDetail(int bookingId) async {
    try {
      isLoadingDetail.value = true;
      detailError.value = '';

      final response = await _repository.fetchBookingRequestDetail(bookingId);

      if (response.success) {
        bookingDetails[bookingId] = response.data;
        return response.data;
      } else {
        detailError.value = response.message;
        return null;
      }
    } on ApiException catch (e) {
      detailError.value = e.message;
      Log.e('Booking detail error: ${e.message}');
      return null;
    } catch (e) {
      detailError.value = 'serverError'.tr;
      Log.e('Booking detail error: $e');
      return null;
    } finally {
      isLoadingDetail.value = false;
    }
  }

  /// Get cached booking detail or fetch if not cached
  Future<BookingRequestDetailModel?> getBookingDetail(int bookingId) async {
    if (bookingDetails.containsKey(bookingId)) {
      return bookingDetails[bookingId];
    }
    return fetchBookingDetail(bookingId);
  }

  /// Accept booking request
  Future<bool> acceptRequest(int bookingId) async {
    try {
      isAccepting.value = true;

      final response = await _repository.acceptBooking(bookingId);

      final success = response['success'] as bool? ?? false;

      if (success) {
        // Remove from upcoming list after successful acceptance
        upcomingRequests.removeWhere((r) => r.id == bookingId);
        // Clear cached detail
        bookingDetails.remove(bookingId);
        return true;
      } else {
        // Show error message
        final message = response['message'] as String? ?? 'failedToAccept'.tr;
        Get.snackbar('error'.tr, message);
        return false;
      }
    } on ApiException catch (e) {
      Get.snackbar('error'.tr, e.message);
      return false;
    } catch (e) {
      Get.snackbar('error'.tr, 'serverError'.tr);
      return false;
    } finally {
      isAccepting.value = false;
    }
  }

  /// Reject booking request
  Future<bool> rejectRequest(int bookingId) async {
    try {
      isRejecting.value = true;

      final response = await _repository.rejectBooking(bookingId);

      final success = response['success'] as bool? ?? false;

      if (success) {
        // Remove from upcoming list after successful rejection
        upcomingRequests.removeWhere((r) => r.id == bookingId);
        pastRequests.removeWhere((r) => r.id == bookingId);
        // Clear cached detail
        bookingDetails.remove(bookingId);
        return true;
      } else {
        // Show error message
        final message = response['message'] as String? ?? 'failedToReject'.tr;
        Get.snackbar('error'.tr, message);
        return false;
      }
    } on ApiException catch (e) {
      Get.snackbar('error'.tr, e.message);
      return false;
    } catch (e) {
      Get.snackbar('error'.tr, 'serverError'.tr);
      return false;
    } finally {
      isRejecting.value = false;
    }
  }

  /// Refresh all requests
  @override
  Future<void> refresh() async {
    await fetchRequests();
  }

  /// Check if currently loading any data
  bool get isLoadingAny => isLoadingUpcoming.value || isLoadingPast.value;
}

/// Simple logger for this controller
class Log {
  static void d(String message) {
    print('[RequestsController] $message');
  }

  static void e(String message) {
    print('[RequestsController ERROR] $message');
  }
}
