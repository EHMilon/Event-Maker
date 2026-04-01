import '../models/booking_request_model.dart';
import '../utils/logger.dart';
import '../constants/api_constant.dart';
import 'api_service.dart';
import 'api_exception.dart';

/// Repository for managing provider booking requests.
/// Handles fetching booking requests, details, and decision actions.
class BookingRequestRepository {
  final ApiService _api = ApiService();

  /// Fetch booking requests list.
  /// GET: api/bookings/provider/booking-request
  /// [tab] - 'upcoming' (default) or 'past'
  Future<BookingRequestListResponse> fetchBookingRequests({
    String tab = 'upcoming',
  }) async {
    try {
      Log.d(
        '=======> BookingRequestRepository: Fetching $tab booking requests',
      );
      // Default upcoming doesn't need tab parameter
      final endpoint = tab == 'upcoming'
          ? ApiConstant.providerBookingRequests
          : '${ApiConstant.providerBookingRequests}?tab=$tab';
      final response = await _api.get(endpoint);
      Log.d('=======> BookingRequestRepository: Response received: $response');
      return BookingRequestListResponse.fromJson(response);
    } on ApiException catch (e) {
      Log.e('=======> BookingRequestRepository: ApiException: ${e.message}');
      throw ApiException(message: e.message);
    } catch (e) {
      Log.e(
        '=======> BookingRequestRepository: Error fetching booking requests: $e',
      );
      throw ApiException(message: 'Failed to fetch booking requests: $e');
    }
  }

  /// Fetch single booking request detail.
  /// GET: api/bookings/provider/booking-request/{id}
  Future<BookingRequestDetailResponse> fetchBookingRequestDetail(
    int bookingId,
  ) async {
    try {
      Log.d(
        '=======> BookingRequestRepository: Fetching booking detail $bookingId',
      );
      final response = await _api.get(
        ApiConstant.providerBookingRequestDetail(bookingId),
      );
      Log.d('=======> BookingRequestRepository: Detail response: $response');
      return BookingRequestDetailResponse.fromJson(response);
    } on ApiException catch (e) {
      Log.e('=======> BookingRequestRepository: ApiException: ${e.message}');
      throw ApiException(message: e.message);
    } catch (e) {
      Log.e(
        '=======> BookingRequestRepository: Error fetching booking detail: $e',
      );
      throw ApiException(message: 'Failed to fetch booking details: $e');
    }
  }

  /// Make decision on booking request (accept/reject).
  /// POST: api/bookings/provider/booking-request-decision/{id}
  /// [action] - 'accepted' or 'rejected'
  Future<Map<String, dynamic>> makeBookingDecision({
    required int bookingId,
    required String action,
  }) async {
    try {
      Log.d(
        '=======> BookingRequestRepository: Making decision $action for booking $bookingId',
      );
      final response = await _api.post(
        ApiConstant.providerBookingRequestDecision(bookingId),
        body: {'action': action},
      );
      Log.d('=======> BookingRequestRepository: Decision response: $response');
      return response;
    } on ApiException catch (e) {
      Log.e('=======> BookingRequestRepository: ApiException: ${e.message}');
      throw ApiException(message: e.message);
    } catch (e) {
      Log.e(
        '=======> BookingRequestRepository: Error making booking decision: $e',
      );
      throw ApiException(message: 'Failed to $action booking: $e');
    }
  }

  /// Accept booking request.
  Future<Map<String, dynamic>> acceptBooking(int bookingId) async {
    return makeBookingDecision(bookingId: bookingId, action: 'accepted');
  }

  /// Reject booking request.
  Future<Map<String, dynamic>> rejectBooking(int bookingId) async {
    return makeBookingDecision(bookingId: bookingId, action: 'rejected');
  }
}
