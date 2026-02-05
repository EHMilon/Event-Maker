import 'package:get/get.dart';
import 'package:event_maker/views/customer_flow/map/map_results_controller.dart';

class MapResultsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MapResultsController>(() => MapResultsController());
  }
}
