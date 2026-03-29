import 'package:get/get.dart';
import 'package:event_maker/services/connectivity_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ConnectivityService(), permanent: true);
  }
}
