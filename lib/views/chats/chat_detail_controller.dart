import 'package:get/get.dart';

/// Controller for the chat detail / conversation screen.
/// TODO: Integrate with backend chat API (WebSocket / REST).
class ChatDetailController extends GetxController {
  final isLoading = true.obs;
  final messageText = ''.obs;
  final RxList<Map<String, dynamic>> messages = <Map<String, dynamic>>[].obs;

  // Chat metadata passed via arguments
  late final String chatId;
  late final String chatName;
  late final String chatImage;
  late final bool isAdminChat;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    chatId = args['id'] ?? '';
    chatName = args['name'] ?? 'Unknown';
    chatImage = args['image'] ?? 'assets/images/person.jpg';
    isAdminChat = args['isAdmin'] ?? false;
    _loadMockMessages();
  }

  /// Load mock message data with a 2s shimmer delay.
  void _loadMockMessages() async {
    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 2));

    if (isAdminChat) {
      // Admin chat – show welcome state
      messages.value = [
        {
          'id': '1',
          'text': 'Hello !',
          'isMe': false,
          'time': '9:41 AM',
          'type': 'header', // Special type for bold welcome
        },
        {
          'id': '2',
          'text': 'Now you can easily contact with the admin.',
          'isMe': false,
          'time': '9:41 AM',
          'type': 'subtitle',
        },
      ];
    } else {
      // Customer chat – normal conversation
      messages.value = [
        {
          'id': '1',
          'text':
              'lorem, sed volutpat lacus ullamcorper.Sed hendrerit ullamcorper elit adipiscing urna. Ut ipsum orci libero, consectetur at.',
          'isMe': true,
          'time': '9:41 AM',
          'type': 'text',
        },
      ];
    }
    isLoading.value = false;
  }

  /// Update message text field value.
  void updateMessageText(String text) {
    messageText.value = text;
  }

  /// Send a new message.
  /// TODO: Integrate with backend to send message via API.
  void sendMessage() {
    if (messageText.value.trim().isEmpty) return;

    // Insert at beginning (index 0) so newest messages appear at bottom
    messages.insert(0, {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'text': messageText.value.trim(),
      'isMe': true,
      'time': _formatCurrentTime(),
      'type': 'text',
    });
    messageText.value = '';
  }

  /// Helper to format current time for display.
  String _formatCurrentTime() {
    final now = DateTime.now();
    final hour = now.hour > 12 ? now.hour - 12 : now.hour;
    final period = now.hour >= 12 ? 'PM' : 'AM';
    final minute = now.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  /// Recommended topics for admin chat (from the mockup).
  List<Map<String, dynamic>> get recommendedTopics => [
    {'emoji': '😊', 'text': 'howCanIImproveMyServices'.tr},
    {'emoji': '👋', 'text': 'howCanIImproveMyServices'.tr},
  ];
}
