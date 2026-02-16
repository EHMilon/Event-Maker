import 'package:event_maker/views/customer_flow/requests/customer_requests_model.dart';
import 'package:get/get.dart';

class CustomerRequestsController extends GetxController {
  final selectedTab = 0.obs;
  final upcomingRequests = <CustomerRequestModel>[].obs;
  final pastRequests = <CustomerRequestModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadMockData();
  }

  void changeTab(int index) => selectedTab.value = index;

  List<CustomerRequestModel> get currentRequests =>
      selectedTab.value == 0 ? upcomingRequests : pastRequests;

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
