import 'package:event_maker/views/service_provider_flow/schedule/schedule_repository.dart';
import 'package:event_maker/views/service_provider_flow/schedule/schedule_controller.dart';
import 'package:get/get.dart';

class ScheduleBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ScheduleRepository());
    Get.put(ScheduleController());
  }
}
