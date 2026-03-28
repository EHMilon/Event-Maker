import '../../../models/schedule_model.dart';

/// Repository abstraction for schedule-related data operations.
/// Currently returns mock data but maintains the same contract
/// that a backend API would provide.
///
/// Backend developer: Replace mock implementations with actual API calls.
/// The method signatures should remain the same.
class ScheduleRepository {
  const ScheduleRepository();

  /// Fetches schedules for a specific date.
  ///
  /// [date] - The date to fetch schedules for.
  ///
  /// Backend: GET /api/v1/provider/schedule?date={yyyy-MM-dd}
  Future<ScheduleResponse> fetchSchedules({required DateTime date}) async {
    // TODO: Replace with actual API call
    // final response = await apiClient.get('/provider/schedule', queryParameters: {
    //   'date': DateFormat('yyyy-MM-dd').format(date),
    // });
    // return ScheduleResponse.fromJson(response.data);

    await Future.delayed(const Duration(milliseconds: 500));

    return _getMockSchedules(date);
  }

  /// Fetches a single schedule by ID.
  ///
  /// [scheduleId] - The ID of the schedule to fetch.
  ///
  /// Backend: GET /api/v1/provider/schedule/{scheduleId}
  Future<ScheduleModel?> fetchScheduleById(String scheduleId) async {
    // TODO: Replace with actual API call
    // final response = await apiClient.get('/provider/schedule/$scheduleId');
    // return ScheduleModel.fromJson(response.data);

    await Future.delayed(const Duration(milliseconds: 300));

    // Mock: return null if not found
    final response = await fetchSchedules(date: DateTime.now());
    try {
      return response.schedules.firstWhere((s) => s.id == scheduleId);
    } catch (_) {
      return null;
    }
  }

  // ========== MOCK DATA ==========
  // Backend developer: Remove this method when integrating real API.

  ScheduleResponse _getMockSchedules(DateTime date) {
    // Return different mock data based on date to simulate real behavior
    final mockSchedules = [
      ScheduleModel(
        id: '1',
        title: 'International Victory Day',
        imageUrl: 'https://picsum.photos/id/10/100/100',
        startTime: _combineDateWithTime(date, 9, 0),
        endTime: _combineDateWithTime(date, 12, 30),
      ),
      ScheduleModel(
        id: '2',
        title: 'Corporate Event Planning',
        imageUrl: 'https://picsum.photos/id/20/100/100',
        startTime: _combineDateWithTime(date, 13, 0),
        endTime: _combineDateWithTime(date, 16, 30),
      ),
      ScheduleModel(
        id: '3',
        title: 'Birthday Party Décor',
        imageUrl: 'https://picsum.photos/id/30/100/100',
        startTime: _combineDateWithTime(date, 17, 0),
        endTime: _combineDateWithTime(date, 21, 30),
      ),
      ScheduleModel(
        id: '4',
        title: 'Kids Safe Parents Night Out',
        imageUrl: 'https://picsum.photos/id/40/100/100',
        startTime: _combineDateWithTime(date, 22, 0),
        endTime: _combineDateWithTime(date, 0, 30).add(const Duration(days: 1)),
      ),
    ];

    return ScheduleResponse.mock(mockSchedules);
  }

  /// Helper to combine a date with specific hours and minutes.
  DateTime _combineDateWithTime(DateTime date, int hour, int minute) {
    return DateTime(date.year, date.month, date.day, hour, minute);
  }
}
