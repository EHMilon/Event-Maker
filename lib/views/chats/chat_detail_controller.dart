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
      messages.value = [
        {
          'id': '1',
          'text': 'How can I improve my sleep?',
          'isMe': true,
          'time': '9:40 AM',
          'type': 'text',
        },
        {
          'id': '2',
          'text': 'Here are some tips that might help you rest better.',
          'isMe': false,
          'time': '9:41 AM',
          'type': 'text',
        },
        {
          'id': '3',
          'text': 'How can I improve my Services?',
          'isMe': true,
          'time': '9:42 AM',
          'type': 'text',
        },
      ];
    } else {
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
  void sendMessage({String? overrideText}) {
    final composed = (overrideText ?? messageText.value).trim();
    if (composed.isEmpty) return;

    messages.insert(0, {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'text': composed,
      'isMe': true,
      'time': _formatCurrentTime(),
      'type': 'text',
    });

    messageText.value = '';

    _scheduleDemoReply();
  }

  void _scheduleDemoReply() {
    Future.delayed(const Duration(milliseconds: 700), () {
      if (isClosed) return;
      final replyText =
          isAdminChat ? 'autoReplyAdmin'.tr : 'autoReplyCustomer'.tr;
      messages.insert(0, {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'text': replyText,
        'isMe': false,
        'time': _formatCurrentTime(),
        'type': 'text',
      });
    });
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
        {'emoji': '😴', 'text': 'howCanIImprovedSleep'.tr},
        {'emoji': '🧘', 'text': 'howCanIImproveMyServices'.tr},
      ];
}
