import 'package:get/get.dart';
import 'add_service_controller.dart';
import 'add_event_controller.dart';
import 'add_training_controller.dart';

/// Binding for add/edit service, event, and training screens
/// Registers all required controllers
class AddScreensBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddServiceController>(() => AddServiceController());
    Get.lazyPut<AddEventController>(() => AddEventController());
    Get.lazyPut<AddTrainingController>(() => AddTrainingController());
  }
}