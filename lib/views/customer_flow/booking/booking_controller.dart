import 'package:get/get.dart';

class BookingController extends GetxController {
  final selectedDateIndex = 1.obs;
  final selectedTimeIndex = 1.obs;

  final selectedMonth = 'December'.obs;
  final selectedYear = '2025'.obs;
  final selectedDuration = '4 Hour'.obs;
  final selectedLocation = 'Sharjah, UAE'.obs;

  final List<String> months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  final List<String> years = ['2025', '2026', '2027', '2028', '2029'];

  final List<String> durations = [
    '1 Hour',
    '2 Hours',
    '3 Hours',
    '4 Hours',
    '5 Hours',
    '6 Hours',
    'Full Day',
  ];

  final List<String> locations = [
    'Sharjah, UAE',
    'Dubai, UAE',
    'Abu Dhabi, UAE',
    'Ajman, UAE',
    'Fujairah, UAE',
    'Ras Al Khaimah, UAE',
  ];

  final List<String> times = [
    '09:00 AM',
    '10:00 AM',
    '11:00 AM',
    '12:00 PM',
    '01:00 PM',
    '02:00 PM',
    '03:00 PM',
    '04:00 PM',
    '05:00 PM',
  ];

  void setSelectedDate(int index) => selectedDateIndex.value = index;
  void setSelectedTime(int index) => selectedTimeIndex.value = index;
  void setSelectedMonth(String month) => selectedMonth.value = month;
  void setSelectedYear(String year) => selectedYear.value = year;
  void setSelectedDuration(String duration) =>
      selectedDuration.value = duration;
  void setSelectedLocation(String location) =>
      selectedLocation.value = location;
}
