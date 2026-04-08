import 'dart:async';
import 'package:event_maker/constants/api_constant.dart';
import 'package:event_maker/models/chat_model.dart';
import 'package:event_maker/services/api_service.dart';

/// Repository for chat-related data operations with backend API integration.
///
/// Endpoints:
/// - GET  /api/chats                     → List all chats
/// - GET  /api/chats/{chatId}           → Get chat details
/// - POST /api/chats/private             → Create private chat (body: {other_user_id})
/// - GET  /api/chats/{chatId}/messages  → List messages
/// - POST /api/chats/{chatId}/messages  → Send message (body: {content})
class ChatRepository {
  final ApiService _apiService = ApiService();

  /// Fetches the list of chats for the current user.
  ///
  /// Backend: GET /api/chats
  Future<List<ChatModel>> fetchChats() async {
    try {
      final response = await _apiService.get(ApiConstant.chats);

      if (response is List) {
        return response
            .map((e) => ChatModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      if (response is Map<String, dynamic>) {
        final chats = response['chats'] as List<dynamic>? ?? [];
        return chats
            .map((e) => ChatModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      // Return empty list on error, UI will handle empty state
      return [];
    }
  }

  /// Fetches a specific chat by ID.
  ///
  /// Backend: GET /api/chats/{chatId}
  Future<ChatModel?> fetchChatById(String chatId) async {
    try {
      final response = await _apiService.get(ApiConstant.chatDetail(chatId));

      if (response is Map<String, dynamic>) {
        return ChatModel.fromJson(response);
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Creates or fetches a private chat with another user.
  /// If a chat already exists, returns the existing chat.
  ///
  /// Backend: POST /api/chats/private
  /// Body: { "other_user_id": "userId" }
  Future<ChatModel?> createOrGetPrivateChat(String otherUserId) async {
    try {
      final response = await _apiService.post(
        ApiConstant.chatsPrivate,
        body: {'other_user_id': otherUserId},
      );

      if (response is Map<String, dynamic>) {
        return ChatModel.fromJson(response);
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Fetches messages for a specific chat.
  ///
  /// Backend: GET /api/chats/{chatId}/messages
  Future<List<ChatMessage>> fetchMessages(String chatId) async {
    try {
      final response = await _apiService.get(ApiConstant.chatMessages(chatId));

      if (response is List) {
        return response
            .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      return [];
    }
  }

  /// Sends a new message in a chat.
  ///
  /// Backend: POST /api/chats/{chatId}/messages
  /// Body: { "content": "message content" }
  Future<ChatMessage?> sendMessage({
    required String chatId,
    required String content,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConstant.sendChatMessage(chatId),
        body: {'content': content},
      );

      if (response is Map<String, dynamic>) {
        return ChatMessage.fromJson(response);
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Marks messages as read in a chat.
  ///
  /// Backend: POST /api/chats/{chatId}/read
  Future<void> markAsRead(String chatId) async {
    try {
      await _apiService.post('${ApiConstant.chats}/$chatId/read');
    } catch (e) {
      // Silently fail - not critical
    }
  }
}

/// Legacy repository for mock data (admin chat).
/// Used for admin chat tab which doesn't have backend yet.
class MockChatRepository {
  const MockChatRepository();

  /// Fetches admin chats (mock data).
  Future<ChatsResponse> fetchAdminChats() async {
    await Future.delayed(const Duration(milliseconds: 350));
    return _getMockAdminChats();
  }

  /// Fetches messages for admin chat (mock data).
  Future<MessagesResponse> fetchAdminMessages({
    required String chatId,
    String? cursor,
  }) async {
    await Future.delayed(const Duration(milliseconds: 350));
    return _getMockAdminMessages(chatId);
  }

  /// Sends a message in admin chat (mock with auto-reply).
  Future<MessageModel> sendAdminMessage({
    required String chatId,
    required String content,
    MessageType type = MessageType.text,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final sentMessage = MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      chatId: chatId,
      senderId: 'current_user',
      content: content,
      createdAt: DateTime.now(),
      type: type,
      isMe: true,
    );

    _triggerAutoReply(chatId, content);
    return sentMessage;
  }

  /// Triggers an auto-reply message (mock behavior).
  void _triggerAutoReply(String chatId, String userMessage) {
    Future.delayed(const Duration(seconds: 2), () {
      final replyContent = _getAutoReplyMessage(userMessage);
      final replyMessage = MessageModel(
        id: 'reply-${DateTime.now().millisecondsSinceEpoch}',
        chatId: chatId,
        senderId: 'admin',
        content: replyContent,
        createdAt: DateTime.now(),
        isMe: false,
      );
      _autoReplyController.add(replyMessage);
    });
  }

  String _getAutoReplyMessage(String userMessage) {
    final lowerMessage = userMessage.toLowerCase();
    if (lowerMessage.contains('hello') ||
        lowerMessage.contains('hi') ||
        lowerMessage.contains('hey')) {
      return 'Hello! 👋 How can I help you today?';
    }
    if (lowerMessage.contains('how are you')) {
      return 'I\'m doing great, thanks for asking! How about you? 😊';
    }
    if (lowerMessage.contains('service') || lowerMessage.contains('booking')) {
      return 'I\'d be happy to help with your service booking! What type of event are you planning?';
    }
    if (lowerMessage.contains('price') ||
        lowerMessage.contains('cost') ||
        lowerMessage.contains('rate')) {
      return 'Our pricing varies based on the service type and duration. Would you like me to send you a detailed quote?';
    }
    if (lowerMessage.contains('thank')) {
      return 'You\'re welcome! Is there anything else I can help you with? 🙏';
    }
    if (lowerMessage.contains('bye') || lowerMessage.contains('goodbye')) {
      return 'Goodbye! Have a wonderful day! 👋';
    }
    final defaultReplies = [
      'That\'s interesting! Tell me more about it.',
      'I understand. How can I assist you further?',
      'Thanks for sharing! Is there anything specific you\'d like to know?',
      'Great question! Let me help you with that.',
      'I\'m here to help. What would you like to know?',
    ];
    return defaultReplies[DateTime.now().second % defaultReplies.length];
  }

  static StreamController<MessageModel>? _autoReplyControllerInternal;
  static StreamController<MessageModel> get _autoReplyController {
    _autoReplyControllerInternal ??= StreamController<MessageModel>.broadcast();
    return _autoReplyControllerInternal!;
  }

  static Stream<MessageModel> get autoReplyStream =>
      _autoReplyController.stream;

  static void disposeAutoReply() {
    _autoReplyControllerInternal?.close();
    _autoReplyControllerInternal = null;
  }

  ChatsResponse _getMockAdminChats() {
    return ChatsResponse(
      chats: [
        ChatModel(
          id: 'admin-1',
          isGroup: false,
          name: 'EventMaker Admin',
          createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
          members: [
            ChatMember(
              id: 'admin',
              email: 'admin@eventmaker.com',
              role: 'admin',
            ),
          ],
          lastMessage: ChatMessage(
            id: 'm1',
            chatId: 'admin-1',
            sender: MessageSender(
              id: 'admin',
              email: 'admin@eventmaker.com',
              role: 'admin',
            ),
            content: 'Hello, how can we assist you today?',
            createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
          ),
        ),
      ],
      hasMore: false,
    );
  }

  MessagesResponse _getMockAdminMessages(String chatId) {
    final now = DateTime.now();
    // Convert MessageModel to ChatMessage for API compatibility
    return MessagesResponse(
      messages: [
        ChatMessage(
          id: '3',
          chatId: chatId,
          sender: MessageSender(id: 'current_user', email: 'user@test.com', role: 'customer'),
          content: 'How can I improve my Services?',
          createdAt: now.subtract(const Duration(minutes: 2)),
        ),
        ChatMessage(
          id: '2',
          chatId: chatId,
          sender: MessageSender(id: 'admin', email: 'admin@test.com', role: 'admin'),
          content: 'Here are some tips that might help you.',
          createdAt: now.subtract(const Duration(minutes: 5)),
        ),
        ChatMessage(
          id: '1',
          chatId: chatId,
          sender: MessageSender(id: 'current_user', email: 'user@test.com', role: 'customer'),
          content: 'How can I improve my experience?',
          createdAt: now.subtract(const Duration(minutes: 10)),
        ),
      ],
      hasMore: false,
    );
  }
}
