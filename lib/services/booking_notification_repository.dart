import '../models/booking_notification_model.dart';
import '../utils/logger.dart';
import '../constants/api_constant.dart';
import 'api_service.dart';
import 'api_exception.dart';

/// Repository for managing provider booking notifications.
/// Handles fetching booking notifications for service providers.
class BookingNotificationRepository {
  final ApiService _api = ApiService();

  /// Fetch provider booking notifications.
  /// GET: api/bookings/provider/booking-notification
  Future<BookingNotificationListResponse> fetchBookingNotifications() async {
    try {
      Log.d(
        '=======> BookingNotificationRepository: Fetching booking notifications',
      );
      final response = await _api.get(ApiConstant.providerBookingNotifications);
      Log.d(
        '=======> BookingNotificationRepository: Notifications response: $response',
      );
      return BookingNotificationListResponse.fromJson(response);
    } on ApiException catch (e) {
      Log.e('=======> BookingNotificationRepository: ApiException: ${e.message}');
      throw ApiException(message: e.message);
    } catch (e) {
      Log.e(
        '=======> BookingNotificationRepository: Error fetching notifications: $e',
      );
      throw ApiException(message: 'Failed to fetch notifications: $e');
    }
  }
}
