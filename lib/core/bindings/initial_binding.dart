import 'package:event_maker/data/services/connectivity_service.dart';
import 'package:get/get.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ConnectivityService(), permanent: true);
  }
}
