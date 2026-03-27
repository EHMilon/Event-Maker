import 'package:get/get.dart';
import 'package:event_maker/views/chats/chat_detail_controller.dart';
import 'package:event_maker/views/chats/chat_view_controller.dart';

/// Simple binding for chat-related views.
class ChatViewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChatViewController>(() => ChatViewController());
    Get.lazyPut<ChatDetailController>(() => ChatDetailController());
  }
}
