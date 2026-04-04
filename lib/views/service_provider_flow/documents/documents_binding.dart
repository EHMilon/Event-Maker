import 'package:event_maker/views/service_provider_flow/documents/documents_controller.dart';
import 'package:get/get.dart';

class DocumentsBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(DocumentsController());
  }
}
