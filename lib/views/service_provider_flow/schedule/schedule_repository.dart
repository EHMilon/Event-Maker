import 'package:event_maker/constants/api_constant.dart';
import 'package:event_maker/models/schedule_model.dart';
import 'package:event_maker/services/api_service.dart';
import 'package:event_maker/services/api_exception.dart';
import 'package:intl/intl.dart';

/// Repository abstraction for schedule-related data operations.
/// Fetches provider schedules from the backend API.
///
/// API Endpoint: GET api/bookings/provider/schedule?date={yyyy-MM-dd}
class ScheduleRepository {
  final ApiService _apiService = ApiService();

  /// Fetches schedules for a specific date.
  ///
  /// [date] - The date to fetch schedules for.
  ///
  /// API: GET api/bookings/provider/schedule?date={yyyy-MM-dd}
  Future<ScheduleResponse> fetchSchedules({required DateTime date}) async {
    try {
      final formattedDate = DateFormat('yyyy-MM-dd').format(date);

      final response = await _apiService.get(
        ApiConstant.providerSchedule,
        queryParams: {'date': formattedDate},
      );

      return ScheduleResponse.fromJson(response as Map<String, dynamic>);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Failed to fetch schedules: $e');
    }
  }

  /// Fetches a single schedule by ID.
  ///
  /// [scheduleId] - The ID of the schedule to fetch.
  ///
  /// API: GET api/bookings/provider/schedule/{scheduleId}
  Future<ScheduleModel?> fetchScheduleById(int scheduleId) async {
    try {
      final response = await _apiService.get(
        '${ApiConstant.providerSchedule}/$scheduleId',
      );

      if (response is Map<String, dynamic>) {
        return ScheduleModel.fromJson(response);
      }
      return null;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Failed to fetch schedule: $e');
    }
  }
}
