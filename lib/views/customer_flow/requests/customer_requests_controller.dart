import 'package:event_maker/views/customer_flow/requests/customer_requests_model.dart';
import 'package:get/get.dart';

class CustomerRequestsController extends GetxController {
  final isLoading = true.obs;
  final upcomingRequests = <CustomerRequestModel>[].obs;
  final pastRequests = <CustomerRequestModel>[].obs;

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

  List<CustomerRequestModel> get currentRequests => [
    ...upcomingRequests,
    ...pastRequests,
  ];

  void _loadMockData() {
    upcomingRequests.assignAll([
      CustomerRequestModel(
        image: 'assets/images/catering.jpg',
        date: '10th Jan - Fri - 4:00 PM',
        title: 'Wedding Catering Services',
        subtitle: 'Grand Hyatt, Dubai',
      ),
      CustomerRequestModel(
        image: 'assets/images/event.png',
        date: '15th Feb - Thu - 11:00 AM',
        title: 'Corporate Event Planning',
        subtitle: 'Business Bay, Dubai',
      ),
      CustomerRequestModel(
        image: 'assets/images/cake.png',
        date: '5th Jan - Sun - 6:00 PM',
        title: 'Birthday Party Décor',
        subtitle: 'Palm Jumeirah, Dubai',
      ),
      CustomerRequestModel(
        image: 'assets/images/concert.png',
        date: '20th Jan - Sat - 8:00 PM',
        title: 'Live Music for Anniversary',
        subtitle: 'Abu Dhabi Corniche',
      ),
    ]);

    pastRequests.assignAll([
      CustomerRequestModel(
        image: 'assets/images/filming.jpg',
        date: '12th Dec - Tue - 3:00 PM',
        title: 'Product Launch Event',
        subtitle: 'Expo City, Dubai',
      ),
    ]);
  }
}
