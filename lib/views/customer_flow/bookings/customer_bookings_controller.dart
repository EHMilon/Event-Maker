import 'package:event_maker/models/service_model.dart';
import 'package:event_maker/views/customer_flow/bookings/customer_requests_model.dart';
import 'package:get/get.dart';

class CustomerBookingsController extends GetxController {
  final isLoading = true.obs;
  final upcomingRequests = <CustomerBookingModel>[].obs;
  final pastRequests = <CustomerBookingModel>[].obs;
  final selectedTabIndex = 0.obs;
  final skeletonRequests = <CustomerBookingModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadData();
  }

  Future<void> _loadData() async {
    isLoading.value = true;
    skeletonRequests.assignAll(List.generate(
      5,
      (index) => CustomerBookingModel(
        image: 'assets/images/catering.jpg',
        date: '10th Jan - Fri - 4:00 PM',
        title: 'Skeleton Title Loading...',
        subtitle: 'Loading Location...',
      ),
    ));
    _loadMockData();
    await Future.delayed(const Duration(seconds: 2));
    isLoading.value = false;
  }

  List<CustomerBookingModel> get currentRequests => [...upcomingRequests, ...pastRequests];

  ServiceModel _createService(String title, String image, String location) {
    return ServiceModel(
      id: 'booking_$title',
      title: title,
      description: 'This is a detailed description for $title. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
      images: [image],
      type: ServiceType.event,
      provider: ServiceProvider(
        name: 'Professional Provider',
        role: 'Event Specialist',
        imageUrl: 'https://i.pravatar.cc/150?u=provider',
        isVerified: true,
      ),
      location: location,
      rating: 4.8,
      reviewCount: 124,
      basePrice: 500,
    );
  }

  void _loadMockData() {
    // Upcoming events (future dates)
    upcomingRequests.assignAll([
      CustomerBookingModel(
        image: 'assets/images/catering.jpg',
        date: '15th Mar - Sun - 4:00 PM',
        title: 'Wedding Catering Services',
        subtitle: 'Grand Hyatt, Dubai',
        service: _createService('Wedding Catering Services', 'assets/images/catering.jpg', 'Grand Hyatt, Dubai'),
      ),
      CustomerBookingModel(
        image: 'assets/images/event.png',
        date: '20th Mar - Fri - 11:00 AM',
        title: 'Corporate Event Planning',
        subtitle: 'Business Bay, Dubai',
        service: _createService('Corporate Event Planning', 'assets/images/event.png', 'Business Bay, Dubai'),
      ),
    ]);

    // Past events (history - past dates)
    pastRequests.assignAll([
      CustomerBookingModel(
        image: 'assets/images/filming.jpg',
        date: '12th Dec - Tue - 3:00 PM',
        title: 'Product Launch Event',
        subtitle: 'Expo City, Dubai',
        service: _createService('Product Launch Event', 'assets/images/filming.jpg', 'Expo City, Dubai'),
      ),
      CustomerBookingModel(
        image: 'assets/images/cake.png',
        date: '5th Jan - Sun - 6:00 PM',
        title: 'Birthday Party Décor',
        subtitle: 'Palm Jumeirah, Dubai',
        service: _createService('Birthday Party Décor', 'assets/images/cake.png', 'Palm Jumeirah, Dubai'),
      ),
    ]);
  }
}
