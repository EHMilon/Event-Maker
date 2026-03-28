import 'package:event_maker/views/service_provider_flow/schedule/schedule_repository.dart';
import 'package:event_maker/services/connectivity_service.dart';
import 'package:event_maker/views/service_provider_flow/schedule/schedule_controller.dart';
import 'package:get/get.dart';

class ScheduleBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure ConnectivityService is available (it's permanent in InitialBinding)
    if (!Get.isRegistered<ConnectivityService>()) {
      Get.put(ConnectivityService(), permanent: true);
    }
    Get.put(ScheduleRepository());
    Get.put(ScheduleController());
  }
}
