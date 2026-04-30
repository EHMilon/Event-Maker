import 'package:event_maker/models/customer_booking_model.dart';
import 'package:event_maker/services/customer_booking_repository.dart';
import 'package:event_maker/services/api_exception.dart';
import 'package:event_maker/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomerBookingsController extends GetxController
    with WidgetsBindingObserver {
  final CustomerBookingRepository _repository = CustomerBookingRepository();

  final isLoading = true.obs;
  final errorMessage = Rxn<String>();
  final upcomingRequests = <CustomerBookingItem>[].obs;
  final pastRequests = <CustomerBookingItem>[].obs;
  final requestedRequests = <CustomerBookingItem>[].obs;
  final selectedTabIndex = 0.obs;
  final skeletonRequests = <CustomerBookingItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _loadData();
  }

  @override
  void onReady() {
    super.onReady();
    // Always reload data when screen is fully presented
    _loadData();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    isLoading.value = true;
    errorMessage.value = null;

    // Show skeleton loading
    skeletonRequests.assignAll(
      List.generate(
        5,
        (index) => CustomerBookingItem(
          id: -1, // Use -1 to indicate skeleton placeholder
          bookingDate: 'Skeleton Loading...',
          startTime: '',
          endTime: '',
          servicesDuration: '',
          title: 'Loading Title...',
          location: 'Loading Location...',
          subtotal: '0.00',
          serviceFee: '0.00',
          totalAmount: '0.00',
          currency: 'AED',
          status: 'pending',
          paymentStatus: 'unpaid',
          service: const CustomerBookingServiceInfo(
            id: 0,
            title: '',
            coverImage: '',
          ),
          createdAt: '',
          updatedAt: '',
        ),
      ),
    );

    // Fetch upcoming, past and requested bookings in parallel
    try {
      final results = await Future.wait([
        _repository.fetchBookings(tab: 'upcoming'),
        _repository.fetchBookings(tab: 'past'),
        _repository.fetchBookings(tab: 'requested'),
      ]);

      final upcomingResponse = results[0];
      final pastResponse = results[1];
      final requestedResponse = results[2];

      if (upcomingResponse.success) {
        upcomingRequests.assignAll(upcomingResponse.data);
      }

      if (pastResponse.success) {
        pastRequests.assignAll(pastResponse.data);
      }

      if (requestedResponse.success) {
        requestedRequests.assignAll(requestedResponse.data);
      }

      Log.d(
        '=======> CustomerBookingsController: Loaded ${upcomingRequests.length} upcoming, ${pastRequests.length} past bookings',
      );
    } on ApiException catch (e) {
      errorMessage.value = e.message;
      Log.e('=======> CustomerBookingsController: ApiException: ${e.message}');
    } catch (e) {
      errorMessage.value = 'Failed to load bookings';
      Log.e('=======> CustomerBookingsController: Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh bookings data (public method for pull-to-refresh)
  Future<void> refreshBookings() async {
    await _loadData();
  }

  /// Reload data (alias for refreshBookings)
  Future<void> reloadData() async {
    await _loadData();
  }

  /// Get combined list of all bookings
  List<CustomerBookingItem> get currentRequests => [
    ...upcomingRequests,
    ...pastRequests,
  ];

  /// Get bookings for the selected tab
  List<CustomerBookingItem> get selectedTabBookings {
    switch (selectedTabIndex.value) {
      case 0:
        return upcomingRequests;
      case 1:
        return requestedRequests;
      case 2:
        return pastRequests;
      default:
        return upcomingRequests;
    }
  }

  /// Check if there are no bookings at all
  bool get hasNoBookings =>
      upcomingRequests.isEmpty &&
      pastRequests.isEmpty &&
      requestedRequests.isEmpty;

  /// Check if a specific tab has no bookings
  bool tabHasNoBookings(int tabIndex) {
    switch (tabIndex) {
      case 0:
        return upcomingRequests.isEmpty;
      case 1:
        return requestedRequests.isEmpty;
      case 2:
        return pastRequests.isEmpty;
      default:
        return upcomingRequests.isEmpty;
    }
  }
}
