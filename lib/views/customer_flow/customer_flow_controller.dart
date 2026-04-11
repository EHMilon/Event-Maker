import 'package:event_maker/views/customer_flow/bookings/customer_bookings_controller.dart';
import 'package:get/get.dart';

class CustomerFlowController extends GetxController {
  final RxInt selectedIndex = 0.obs;

  void changeIndex(int index) {
    selectedIndex.value = index;

    // Refresh bookings data when switching to bookings tab (index 3)
    if (index == 3) {
      try {
        final bookingsController = Get.find<CustomerBookingsController>();
        bookingsController.reloadData();
      } catch (e) {
        // Controller might not be initialized yet
      }
    }
  }
}
