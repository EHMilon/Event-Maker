import 'package:event_maker/views/customer_flow/customer_flow_controller.dart';
import 'package:event_maker/views/customer_flow/home/home_controller.dart';
import 'package:event_maker/views/customer_flow/map/map_controller.dart';
import 'package:event_maker/views/profile/profile_controller.dart';
import 'package:event_maker/views/services/services_controller.dart';
import 'package:get/get.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CustomerFlowController>(() => CustomerFlowController());
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<MapController>(() => MapController());
    Get.lazyPut<ProfileController>(() => ProfileController());
    Get.lazyPut<ServicesController>(() => ServicesController());
  }
}
