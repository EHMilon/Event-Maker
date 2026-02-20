import 'package:get/get.dart';
import 'chat_view_controller.dart';

/// Binding for ChatView - registers ChatViewController
class ChatViewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChatViewController>(() => ChatViewController());
  }
}
