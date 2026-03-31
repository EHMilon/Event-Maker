import 'package:event_maker/global/data_controller.dart';
import 'package:event_maker/global/loading_controller.dart';
import 'package:get/get.dart';
import 'package:event_maker/services/connectivity_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ConnectivityService(), permanent: true);
    Get.put(LoadingController(), permanent: true);
    Get.put(DataController(), permanent: true);
  }
}
