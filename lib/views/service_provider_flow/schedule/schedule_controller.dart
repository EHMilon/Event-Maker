import 'package:event_maker/models/schedule_model.dart';
import 'package:event_maker/repository/schedule_repository.dart';
import 'package:event_maker/services/connectivity_service.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ScheduleController extends GetxController {
  late final ScheduleRepository _scheduleRepository;
  late final ConnectivityService _connectivityService;

  // Observables for UI state
  final isLoading = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;
  final schedules = <ScheduleModel>[].obs;

  // Date selection observables
  final selectedDate = DateTime.now().obs;
  final focusedDate = DateTime.now().obs;
  final currentMonth = DateFormat('MMMM').format(DateTime.now()).obs;
  final currentYear = DateFormat('yyyy').format(DateTime.now()).obs;

  @override
  void onInit() {
    super.onInit();
    _scheduleRepository = Get.find<ScheduleRepository>();
    _connectivityService = Get.find<ConnectivityService>();
    fetchSchedules();
  }

  /// Fetches schedules for the selected date.
  Future<void> fetchSchedules() async {
    if (!_connectivityService.isConnected.value) {
      hasError.value = true;
      errorMessage.value = 'noInternet'.tr;
      Get.snackbar('error'.tr, 'noInternet'.tr);
      return;
    }

    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final response = await _scheduleRepository.fetchSchedules(
        date: selectedDate.value,
      );

      schedules.value = response.schedules;
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
      Get.snackbar('error'.tr, 'serverError'.tr);
    } finally {
      isLoading.value = false;
    }
  }

  /// Refreshes schedules (used by pull-to-refresh).
  Future<void> refreshSchedules() async {
    await fetchSchedules();
  }

  /// Selects a date and fetches schedules for that date.
  void selectDate(DateTime date) {
    selectedDate.value = date;
    fetchSchedules();
  }

  /// Navigates to the next month.
  void nextMonth() {
    focusedDate.value = DateTime(
      focusedDate.value.year,
      focusedDate.value.month + 1,
    );
    updateMonthYear();
  }

  /// Navigates to the previous month.
  void prevMonth() {
    focusedDate.value = DateTime(
      focusedDate.value.year,
      focusedDate.value.month - 1,
    );
    updateMonthYear();
  }

  /// Navigates to the next year.
  void nextYear() {
    focusedDate.value = DateTime(
      focusedDate.value.year + 1,
      focusedDate.value.month,
    );
    updateMonthYear();
  }

  /// Navigates to the previous year.
  void prevYear() {
    focusedDate.value = DateTime(
      focusedDate.value.year - 1,
      focusedDate.value.month,
    );
    updateMonthYear();
  }

  /// Updates the displayed month and year strings.
  void updateMonthYear() {
    currentMonth.value = DateFormat('MMMM').format(focusedDate.value);
    currentYear.value = DateFormat('yyyy').format(focusedDate.value);
  }

  /// Returns a list of DateTime objects for the week containing the selected date.
  List<DateTime> getDaysInWeek() {
    final now = selectedDate.value;
    final firstDayOfWeek = now.subtract(Duration(days: now.weekday - 1));
    return List.generate(
      7,
      (index) => firstDayOfWeek.add(Duration(days: index)),
    );
  }

  /// Checks if a date is the same as the selected date.
  bool isSelectedDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date) ==
        DateFormat('yyyy-MM-dd').format(selectedDate.value);
  }

  /// Retries fetching schedules after an error.
  void retry() {
    fetchSchedules();
  }
}
