import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ScheduleController extends GetxController {
  var isLoading = false.obs;
  var selectedDate = DateTime.now().obs;
  var focusedDate = DateTime.now().obs;

  var currentMonth = DateFormat('MMMM').format(DateTime.now()).obs;
  var currentYear = DateFormat('yyyy').format(DateTime.now()).obs;

  var services = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    // TODO: Fetch schedule from backend API
    _loadMockServices();
  }

  void _loadMockServices() {
    isLoading.value = true;
    // Simulate network delay
    Future.delayed(const Duration(seconds: 2), () {
      services.value = [
        {
          'time': '09:00 AM - 12:30 pm',
          'title': 'International Victory Day',
          'type': 'Event',
          'color': const Color(0xFFE9D5FF),
          'image': 'https://picsum.photos/id/10/100/100',
        },
        {
          'time': '01:00 pm - 04:30 pm',
          'title': 'Corporate Event Planning',
          'type': 'Meeting',
          'color': const Color(0xFFCCFBF1),
          'image': 'https://picsum.photos/id/20/100/100',
        },
        {
          'time': '05:00 PM - 09:30 pm',
          'title': 'Birthday Party Décor',
          'type': 'Party',
          'color': const Color(0xFFDBEAFE),
          'image': 'https://picsum.photos/id/30/100/100',
        },
        {
          'time': '10:00 PM - 12:30 am',
          'title': 'Kids Safe Parents Night Out',
          'type': 'Event',
          'color': const Color(0xFFFEE2E2),
          'image': 'https://picsum.photos/id/40/100/100',
        },
      ];
      isLoading.value = false;
    });
  }

  void selectDate(DateTime date) {
    selectedDate.value = date;
    // In a real app, we would fetch services for this date
    _loadMockServices();
  }

  void nextMonth() {
    focusedDate.value = DateTime(
      focusedDate.value.year,
      focusedDate.value.month + 1,
    );
    updateMonthYear();
  }

  void prevMonth() {
    focusedDate.value = DateTime(
      focusedDate.value.year,
      focusedDate.value.month - 1,
    );
    updateMonthYear();
  }

  void nextYear() {
    focusedDate.value = DateTime(
      focusedDate.value.year + 1,
      focusedDate.value.month,
    );
    updateMonthYear();
  }

  void prevYear() {
    focusedDate.value = DateTime(
      focusedDate.value.year - 1,
      focusedDate.value.month,
    );
    updateMonthYear();
  }

  void updateMonthYear() {
    currentMonth.value = DateFormat('MMMM').format(focusedDate.value);
    currentYear.value = DateFormat('yyyy').format(focusedDate.value);
  }

  List<DateTime> getDaysInWeek() {
    final now = selectedDate.value;
    final firstDayOfWeek = now.subtract(Duration(days: now.weekday - 1));
    return List.generate(
      7,
      (index) => firstDayOfWeek.add(Duration(days: index)),
    );
  }
}
