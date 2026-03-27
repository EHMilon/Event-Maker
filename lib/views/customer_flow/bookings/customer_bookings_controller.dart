import 'package:event_maker/views/customer_flow/bookings/customer_requests_model.dart';
import 'package:get/get.dart';

class CustomerBookingsController extends GetxController {
  final isLoading = true.obs;
  final upcomingRequests = <CustomerBookingModel>[].obs;
  final pastRequests = <CustomerBookingModel>[].obs;
  final selectedTabIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadData();
  }

  Future<void> _loadData() async {
    isLoading.value = true;
    _loadMockData();
    await Future.delayed(const Duration(seconds: 2));
    isLoading.value = false;
  }

  List<CustomerBookingModel> get currentRequests => [...upcomingRequests, ...pastRequests];

  void _loadMockData() {
    final now = DateTime.now();

    // Upcoming events (future dates)
    upcomingRequests.assignAll([
      CustomerBookingModel(
        image: 'assets/images/catering.jpg',
        date: '15th Mar - Sun - 4:00 PM',
        title: 'Wedding Catering Services',
        subtitle: 'Grand Hyatt, Dubai',
      ),
      CustomerBookingModel(
        image: 'assets/images/event.png',
        date: '20th Mar - Fri - 11:00 AM',
        title: 'Corporate Event Planning',
        subtitle: 'Business Bay, Dubai',
      ),
    ]);

    // Past events (history - past dates)
    pastRequests.assignAll([
      CustomerBookingModel(image: 'assets/images/filming.jpg', date: '12th Dec - Tue - 3:00 PM', title: 'Product Launch Event', subtitle: 'Expo City, Dubai'),
      CustomerBookingModel(image: 'assets/images/cake.png', date: '5th Jan - Sun - 6:00 PM', title: 'Birthday Party Décor', subtitle: 'Palm Jumeirah, Dubai'),
    ]);
  }
}
