import 'dart:async';
import 'package:get/get.dart';
import 'package:event_maker/models/chat_model.dart';
import 'package:event_maker/views/chats/chat_repository.dart';

/// Controller for the chat detail / conversation screen.
/// Uses [ChatRepository] for real API data and [MockChatRepository] for admin chat.
class ChatDetailController extends GetxController {
  final ChatRepository _repository = ChatRepository();
  final MockChatRepository _mockRepository = MockChatRepository();

  final isLoading = true.obs;
  final isSending = false.obs;
  final messageText = ''.obs;
  final hasError = false.obs;
  String? errorMessage;

  // Messages list (API messages)
  final RxList<ChatMessage> messages = <ChatMessage>[].obs;

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

  // Admin messages (mock data) - for admin chat tab
  final RxList<MessageModel> adminMessages = <MessageModel>[].obs;

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
    
    if (isAdminChat) {
      _listenToAutoReplies();
    }
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
      if (isAdminChat) {
        // Load mock admin messages
        final response = await _mockRepository.fetchAdminMessages(chatId: chatId);
        // Convert ChatMessage to MessageModel for UI compatibility
        adminMessages.value = response.messages.map((m) => MessageModel(
          id: m.id,
          chatId: m.chatId,
          senderId: m.sender.id,
          senderEmail: m.sender.email,
          senderRole: m.sender.role,
          content: m.content,
          createdAt: m.createdAt,
          isMe: false, // Will be set based on sender
        )).toList();
      } else {
        // Load real messages from API
        final fetchedMessages = await _repository.fetchMessages(chatId);
        messages.value = fetchedMessages;
        
        // Mark messages as read when opening chat
        if (fetchedMessages.isNotEmpty) {
          await _repository.markAsRead(chatId);
        }
      }
    } catch (e) {
      hasError.value = true;
      errorMessage = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  /// Loads more messages (pagination).
  Future<void> loadMoreMessages() async {
    if (isLoadingMore.value || !hasMoreMessages || nextCursor == null) return;

    isLoadingMore.value = true;

    try {
      if (isAdminChat) {
        final response = await _mockRepository.fetchAdminMessages(
          chatId: chatId,
          cursor: nextCursor,
        );
        // Convert and add messages
        adminMessages.addAll(response.messages.map((m) => MessageModel(
          id: m.id,
          chatId: m.chatId,
          senderId: m.sender.id,
          content: m.content,
          createdAt: m.createdAt,
          isMe: false,
        )));
      } else {
        final fetchedMessages = await _repository.fetchMessages(chatId);
        messages.addAll(fetchedMessages);
      }
      hasMoreMessages = false; // API doesn't support pagination yet
    } catch (e) {
      // Handle pagination error
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

    try {
      if (isAdminChat) {
        // Send mock admin message
        final sentMessage = await _mockRepository.sendAdminMessage(
          chatId: chatId,
          content: composed,
        );
        adminMessages.insert(0, sentMessage);
      } else {
        // Send real message via API
        final sentMessage = await _repository.sendMessage(
          chatId: chatId,
          content: composed,
        );
        
        if (sentMessage != null) {
          messages.insert(0, sentMessage);
        }
      }
      messageText.value = '';
    } catch (e) {
      hasError.value = true;
      errorMessage = 'Failed to send message: $e';
    } finally {
      isSending.value = false;
    }
  }

  /// Listens to auto-reply messages from the mock repository.
  void _listenToAutoReplies() {
    _autoReplySubscription = MockChatRepository.autoReplyStream.listen((
      replyMessage,
    ) {
      if (replyMessage.chatId == chatId) {
        adminMessages.insert(0, replyMessage);
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
