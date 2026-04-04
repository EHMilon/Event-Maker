import '../models/customer_booking_model.dart';
import '../utils/logger.dart';
import '../constants/api_constant.dart';
import 'api_service.dart';
import 'api_exception.dart';

/// Repository for customer-side booking operations.
/// Handles sending booking requests, fetching booking list, and booking notifications.
class CustomerBookingRepository {
  final ApiService _api = ApiService();

  /// Send a booking request to a service provider.
  /// POST: api/bookings/send-bookings-request
  ///
  /// Body parameters:
  /// - service_id: int - The service ID to book
  /// - selected_package_id: int - Selected package ID
  /// - booking_date: String - Date in YYYY-MM-DD format
  /// - start_time: String - Start time in HH:MM:SS format
  /// - services_duration: int - Duration in hours
  /// - special_request: String? - Optional special requests
  /// - location: String - Service location
  /// - latitude: String - Location latitude
  /// - longitude: String - Location longitude
  Future<CustomerBookingDetailResponse> sendBookingRequest({
    required int serviceId,
    required int selectedPackageId,
    required String bookingDate,
    required String startTime,
    required int servicesDuration,
    String? specialRequest,
    required String location,
    required String latitude,
    required String longitude,
  }) async {
    try {
      Log.d('=======> CustomerBookingRepository: Sending booking request');

      final body = {
        'service_id': serviceId,
        'selected_package_id': selectedPackageId,
        'booking_date': bookingDate,
        'start_time': startTime,
        'services_duration': servicesDuration,
        'special_request': specialRequest,
        'location': location,
        'latitude': latitude,
        'longitude': longitude,
      };

      // Remove null values
      body.removeWhere((key, value) => value == null);

      final response = await _api.post(
        ApiConstant.sendBookingRequest,
        body: body,
      );

      Log.d(
        '=======> CustomerBookingRepository: Booking request sent: $response',
      );
      return CustomerBookingDetailResponse.fromJson(response);
    } on ApiException catch (e) {
      Log.e('=======> CustomerBookingRepository: ApiException: ${e.message}');
      throw ApiException(message: e.message);
    } catch (e) {
      Log.e('=======> CustomerBookingRepository: Error sending booking: $e');
      throw ApiException(message: 'Failed to send booking request: $e');
    }
  }

  /// Fetch customer booking list.
  /// GET: api/bookings/request-list?tab=upcoming|past
  ///
  /// [tab] - 'upcoming' (default) or 'past'
  Future<CustomerBookingListResponse> fetchBookings({
    String tab = 'upcoming',
  }) async {
    try {
      Log.d('=======> CustomerBookingRepository: Fetching $tab bookings');

      final endpoint = tab == 'upcoming'
          ? ApiConstant.customerBookingList
          : '${ApiConstant.customerBookingList}?tab=$tab';

      final response = await _api.get(endpoint);
      Log.d('=======> CustomerBookingRepository: Bookings response: $response');
      return CustomerBookingListResponse.fromJson(response);
    } on ApiException catch (e) {
      Log.e('=======> CustomerBookingRepository: ApiException: ${e.message}');
      throw ApiException(message: e.message);
    } catch (e) {
      Log.e('=======> CustomerBookingRepository: Error fetching bookings: $e');
      throw ApiException(message: 'Failed to fetch bookings: $e');
    }
  }

  /// Fetch single booking detail.
  /// GET: api/bookings/request/detail/{id}
  Future<CustomerBookingDetailResponse> fetchBookingDetail(
    int bookingId,
  ) async {
    try {
      Log.d(
        '=======> CustomerBookingRepository: Fetching booking detail $bookingId',
      );

      final response = await _api.get(
        ApiConstant.customerBookingDetail(bookingId),
      );

      Log.d('=======> CustomerBookingRepository: Detail response: $response');
      return CustomerBookingDetailResponse.fromJson(response);
    } on ApiException catch (e) {
      Log.e('=======> CustomerBookingRepository: ApiException: ${e.message}');
      throw ApiException(message: e.message);
    } catch (e) {
      Log.e('=======> CustomerBookingRepository: Error fetching detail: $e');
      throw ApiException(message: 'Failed to fetch booking details: $e');
    }
  }

  /// Fetch customer booking notifications.
  /// GET: api/bookings/notification-list
  Future<CustomerBookingNotificationListResponse> fetchNotifications() async {
    try {
      Log.d('=======> CustomerBookingRepository: Fetching notifications');

      final response = await _api.get(ApiConstant.customerBookingNotifications);

      Log.d(
        '=======> CustomerBookingRepository: Notifications response: $response',
      );
      return CustomerBookingNotificationListResponse.fromJson(response);
    } on ApiException catch (e) {
      Log.e('=======> CustomerBookingRepository: ApiException: ${e.message}');
      throw ApiException(message: e.message);
    } catch (e) {
      Log.e(
        '=======> CustomerBookingRepository: Error fetching notifications: $e',
      );
      throw ApiException(message: 'Failed to fetch notifications: $e');
    }
  }
}
