import 'package:event_maker/views/customer_flow/customer_flow_controller.dart';
import 'package:event_maker/views/customer_flow/home/home_controller.dart';
import 'package:event_maker/views/customer_flow/map/map_controller.dart';
import 'package:event_maker/views/customer_flow/requests/customer_requests_controller.dart';
import 'package:event_maker/views/service_provider_flow/profile/profile_controller.dart';
import 'package:event_maker/views/service_provider_flow/services/sp_services_controller.dart';
import 'package:get/get.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CustomerFlowController>(() => CustomerFlowController());
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<MapController>(() => MapController());
    Get.lazyPut<CustomerRequestsController>(() => CustomerRequestsController());
    Get.lazyPut<ProfileController>(() => ProfileController());
    Get.lazyPut<SPServicesController>(() => SPServicesController());
  }
}
