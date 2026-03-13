import 'package:get/get.dart';
import 'add_service_controller.dart';

/// Binding for add/edit service, event, and training screens
/// Registers all required controllers
class AddScreensBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddServiceController>(() => AddServiceController());
  }
}
