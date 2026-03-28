import 'dart:async';
import 'package:get/get.dart';
import 'package:event_maker/models/chat_model.dart';
import 'package:event_maker/views/chats/chat_repository.dart';

/// Controller for the chat detail / conversation screen.
/// Uses [ChatRepository] for data fetching with backend-compatible patterns.
class ChatDetailController extends GetxController {
  final ChatRepository _repository = const ChatRepository();

  final isLoading = true.obs;
  final isSending = false.obs;
  final messageText = ''.obs;
  final hasError = false.obs;
  String? errorMessage;

  // Typed messages list
  final RxList<MessageModel> messages = <MessageModel>[].obs;

  // Pagination support
  bool hasMoreMessages = false;
  String? nextCursor;
  final isLoadingMore = false.obs;

  // Chat metadata passed via arguments
  late final String chatId;
  late final String chatName;
  late final String chatImage;
  late final bool isAdminChat;

  // Auto-reply stream subscription
  StreamSubscription<MessageModel>? _autoReplySubscription;

  // Recommended topics for admin chat
  List<RecommendedTopic> get recommendedTopics => [
    RecommendedTopic(emoji: '📅', text: 'How can I book a service?'),
    RecommendedTopic(emoji: '💰', text: 'What are your pricing options?'),
    RecommendedTopic(emoji: '🎯', text: 'How can I improve my services?'),
  ];

  @override
  void onInit() {
    super.onInit();
    _parseArguments();
    loadMessages();
    _listenToAutoReplies();
  }

  @override
  void onClose() {
    _autoReplySubscription?.cancel();
    super.onClose();
  }

  /// Parses navigation arguments.
  void _parseArguments() {
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    chatId = args['id'] as String? ?? '';
    chatName = args['name'] as String? ?? 'Unknown';
    chatImage = args['image'] as String? ?? 'assets/images/person.jpg';
    isAdminChat = args['isAdmin'] as bool? ?? false;
  }

  /// Loads messages for the current chat.
  Future<void> loadMessages() async {
    isLoading.value = true;
    hasError.value = false;
    errorMessage = null;

    try {
      final response = await _repository.fetchMessages(chatId: chatId);
      messages.value = response.messages;
      hasMoreMessages = response.hasMore;
      nextCursor = response.nextCursor;

      // Mark messages as read when opening chat
      if (messages.isNotEmpty) {
        await _repository.markAsRead(chatId);
      }
    } catch (e) {
      hasError.value = true;
      errorMessage = e.toString();
      // TODO: Handle error appropriately
    } finally {
      isLoading.value = false;
    }
  }

  /// Loads more messages (pagination).
  Future<void> loadMoreMessages() async {
    if (isLoadingMore.value || !hasMoreMessages || nextCursor == null) return;

    isLoadingMore.value = true;

    try {
      final response = await _repository.fetchMessages(
        chatId: chatId,
        cursor: nextCursor,
      );
      messages.addAll(response.messages);
      hasMoreMessages = response.hasMore;
      nextCursor = response.nextCursor;
    } catch (e) {
      // TODO: Handle pagination error
    } finally {
      isLoadingMore.value = false;
    }
  }

  /// Updates the message text field value.
  void updateMessageText(String text) {
    messageText.value = text;
  }

  /// Sends a new message.
  Future<void> sendMessage({String? overrideText}) async {
    final composed = (overrideText ?? messageText.value).trim();
    if (composed.isEmpty || isSending.value) return;

    isSending.value = true;

    // Optimistically add message to UI
    final optimisticMessage = MessageModel(
      id: 'temp-${DateTime.now().millisecondsSinceEpoch}',
      chatId: chatId,
      senderId: 'current_user',
      content: composed,
      createdAt: DateTime.now(),
      isMe: true,
    );

    messages.insert(0, optimisticMessage);
    messageText.value = '';

    try {
      // Send message via repository
      final sentMessage = await _repository.sendMessage(
        chatId: chatId,
        content: composed,
      );

      // Replace optimistic message with actual message from server
      final index = messages.indexWhere((m) => m.id == optimisticMessage.id);
      if (index != -1) {
        messages[index] = sentMessage;
      }
    } catch (e) {
      // Remove optimistic message on failure
      messages.removeWhere((m) => m.id == optimisticMessage.id);
      hasError.value = true;
      errorMessage = 'Failed to send message: $e';
      // TODO: Show error to user
    } finally {
      isSending.value = false;
    }
  }

  /// Listens to auto-reply messages from the repository.
  void _listenToAutoReplies() {
    _autoReplySubscription = ChatRepository.autoReplyStream.listen((
      replyMessage,
    ) {
      // Only add if it's for this chat
      if (replyMessage.chatId == chatId) {
        messages.insert(0, replyMessage);
      }
    });
  }
}

/// Model for recommended topics in admin chat.
class RecommendedTopic {
  final String emoji;
  final String text;

  const RecommendedTopic({required this.emoji, required this.text});
}
