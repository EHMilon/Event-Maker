import 'package:event_maker/models/customer_booking_model.dart';
import 'package:event_maker/services/customer_booking_repository.dart';
import 'package:event_maker/services/api_exception.dart';
import 'package:event_maker/utils/logger.dart';
import 'package:get/get.dart';

class CustomerBookingsController extends GetxController {
  final CustomerBookingRepository _repository = CustomerBookingRepository();

  final isLoading = true.obs;
  final errorMessage = Rxn<String>();
  final upcomingRequests = <CustomerBookingItem>[].obs;
  final pastRequests = <CustomerBookingItem>[].obs;
  final selectedTabIndex = 0.obs;
  final skeletonRequests = <CustomerBookingItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadData();
  }

  Future<void> _loadData() async {
    isLoading.value = true;
    errorMessage.value = null;

    // Show skeleton loading
    skeletonRequests.assignAll(List.generate(
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
    ));

    // Fetch both upcoming and past bookings in parallel
    try {
      final results = await Future.wait([
        _repository.fetchBookings(tab: 'upcoming'),
        _repository.fetchBookings(tab: 'past'),
      ]);

      final upcomingResponse = results[0];
      final pastResponse = results[1];

      if (upcomingResponse.success) {
        upcomingRequests.assignAll(upcomingResponse.data);
      }

      if (pastResponse.success) {
        pastRequests.assignAll(pastResponse.data);
      }

      Log.d('=======> CustomerBookingsController: Loaded ${upcomingRequests.length} upcoming, ${pastRequests.length} past bookings');
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

  /// Refresh bookings data
  Future<void> refreshBookings() async {
    await _loadData();
  }

  /// Get combined list of all bookings
  List<CustomerBookingItem> get currentRequests => [...upcomingRequests, ...pastRequests];

  /// Get bookings for the selected tab
  List<CustomerBookingItem> get selectedTabBookings =>
      selectedTabIndex.value == 0 ? upcomingRequests : pastRequests;

  /// Check if there are no bookings at all
  bool get hasNoBookings => upcomingRequests.isEmpty && pastRequests.isEmpty;

  /// Check if a specific tab has no bookings
  bool tabHasNoBookings(int tabIndex) =>
      tabIndex == 0 ? upcomingRequests.isEmpty : pastRequests.isEmpty;
}
