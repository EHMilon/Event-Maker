import 'dart:async';
import '../models/chat_model.dart';

/// Repository abstraction for chat-related data operations.
/// Currently returns mock data but maintains the same contract
/// that a backend API would provide.
///
/// Backend developer: Replace mock implementations with actual API calls.
/// The method signatures should remain the same.
class ChatRepository {
  const ChatRepository();

  /// Fetches the list of chats for the current user.
  ///
  /// [isAdmin] - If true, fetches admin chats; otherwise customer chats.
  /// [cursor] - Pagination cursor for loading more chats.
  ///
  /// Backend: GET /chats?is_admin={isAdmin}&cursor={cursor}
  Future<ChatsResponse> fetchChats({
    bool isAdmin = false,
    String? cursor,
  }) async {
    // TODO: Replace with actual API call
    // final response = await apiClient.get('/chats', queryParameters: {
    //   'is_admin': isAdmin,
    //   if (cursor != null) 'cursor': cursor,
    // });
    // return ChatsResponse.fromJson(response.data);

    await Future.delayed(const Duration(milliseconds: 350));

    return _getMockChats(isAdmin);
  }

  /// Fetches messages for a specific chat.
  ///
  /// [chatId] - The ID of the chat to fetch messages for.
  /// [cursor] - Pagination cursor for loading older messages.
  ///
  /// Backend: GET /chats/{chatId}/messages?cursor={cursor}
  Future<MessagesResponse> fetchMessages({
    required String chatId,
    String? cursor,
  }) async {
    // TODO: Replace with actual API call
    // final response = await apiClient.get('/chats/$chatId/messages', queryParameters: {
    //   if (cursor != null) 'cursor': cursor,
    // });
    // return MessagesResponse.fromJson(response.data);

    await Future.delayed(const Duration(milliseconds: 350));

    return _getMockMessages(chatId);
  }

  /// Sends a new message in a chat.
  ///
  /// [chatId] - The ID of the chat to send the message to.
  /// [content] - The message content.
  /// [type] - The type of message (text, image, file).
  ///
  /// Backend: POST /chats/{chatId}/messages
  /// Body: { "content": "...", "type": "text" }
  Future<MessageModel> sendMessage({
    required String chatId,
    required String content,
    MessageType type = MessageType.text,
    String? attachmentUrl,
    String? attachmentName,
  }) async {
    // TODO: Replace with actual API call
    // final response = await apiClient.post('/chats/$chatId/messages', data: {
    //   'content': content,
    //   'type': type.toJsonString(),
    //   if (attachmentUrl != null) 'attachment_url': attachmentUrl,
    //   if (attachmentName != null) 'attachment_name': attachmentName,
    // });
    // return MessageModel.fromJson(response.data);

    await Future.delayed(const Duration(milliseconds: 200));

    // Return a mock sent message
    final sentMessage = MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      chatId: chatId,
      senderId: 'current_user',
      content: content,
      createdAt: DateTime.now(),
      type: type,
      isMe: true,
      attachmentUrl: attachmentUrl,
      attachmentName: attachmentName,
    );

    // Trigger auto-reply after a short delay (mock behavior)
    _triggerAutoReply(chatId, content);

    return sentMessage;
  }

  /// Triggers an auto-reply message (mock behavior for testing).
  /// In production, this would be handled by the backend or WebSocket.
  void _triggerAutoReply(String chatId, String userMessage) {
    Future.delayed(const Duration(seconds: 2), () {
      final replyContent = _getAutoReplyMessage(userMessage);
      final replyMessage = MessageModel(
        id: 'reply-${DateTime.now().millisecondsSinceEpoch}',
        chatId: chatId,
        senderId: chatId.startsWith('admin') ? 'admin' : 'bot',
        content: replyContent,
        createdAt: DateTime.now(),
        isMe: false,
      );

      // Notify ChatProvider about the new message
      _autoReplyController.add(replyMessage);
    });
  }

  /// Generates an appropriate auto-reply based on user message.
  String _getAutoReplyMessage(String userMessage) {
    final lowerMessage = userMessage.toLowerCase();

    // Simple keyword-based replies
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

    // Default replies
    final defaultReplies = [
      'That\'s interesting! Tell me more about it.',
      'I understand. How can I assist you further?',
      'Thanks for sharing! Is there anything specific you\'d like to know?',
      'Great question! Let me help you with that.',
      'I\'m here to help. What would you like to know?',
    ];

    return defaultReplies[DateTime.now().second % defaultReplies.length];
  }

  /// Stream controller for auto-reply messages (used by ChatProvider).
  static StreamController<MessageModel>? _autoReplyControllerInternal;
  static StreamController<MessageModel> get _autoReplyController {
    _autoReplyControllerInternal ??= StreamController<MessageModel>.broadcast();
    return _autoReplyControllerInternal!;
  }

  /// Get the auto-reply stream for ChatProvider to listen to.
  static Stream<MessageModel> get autoReplyStream =>
      _autoReplyController.stream;

  /// Dispose the auto-reply stream controller.
  /// Call this when the app is shutting down to prevent memory leaks.
  static void disposeAutoReply() {
    _autoReplyControllerInternal?.close();
    _autoReplyControllerInternal = null;
  }

  /// Marks messages as read in a chat.
  ///
  /// [chatId] - The ID of the chat to mark as read.
  ///
  /// Backend: POST /chats/{chatId}/read
  Future<void> markAsRead(String chatId) async {
    // TODO: Replace with actual API call
    // await apiClient.post('/chats/$chatId/read');
    await Future.delayed(const Duration(milliseconds: 100));
  }

  /// Creates a new chat with a participant.
  ///
  /// [participantId] - The ID of the user to start a chat with.
  /// [isAdminChat] - Whether this is an admin chat.
  ///
  /// Backend: POST /chats
  /// Body: { "participant_id": "...", "is_admin_chat": false }
  Future<ChatModel> createChat({
    required String participantId,
    bool isAdminChat = false,
  }) async {
    // TODO: Replace with actual API call
    // final response = await apiClient.post('/chats', data: {
    //   'participant_id': participantId,
    //   'is_admin_chat': isAdminChat,
    // });
    // return ChatModel.fromJson(response.data);

    await Future.delayed(const Duration(milliseconds: 300));

    return ChatModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      participant: ChatParticipant(id: participantId, name: 'New Chat'),
      lastMessage: MessageModel(
        id: 'temp',
        chatId: 'temp',
        senderId: 'system',
        content: '',
        createdAt: DateTime.now(),
      ),
      isAdminChat: isAdminChat,
      updatedAt: DateTime.now(),
    );
  }

  /// Searches chats by participant name or message content.
  ///
  /// [query] - The search query.
  /// [isAdmin] - Whether to search in admin chats.
  ///
  /// Backend: GET /chats/search?q={query}&is_admin={isAdmin}
  Future<ChatsResponse> searchChats({
    required String query,
    bool isAdmin = false,
  }) async {
    // TODO: Replace with actual API call
    // final response = await apiClient.get('/chats/search', queryParameters: {
    //   'q': query,
    //   'is_admin': isAdmin,
    // });
    // return ChatsResponse.fromJson(response.data);

    await Future.delayed(const Duration(milliseconds: 200));

    final allChats = _getMockChats(isAdmin);
    if (query.isEmpty) return allChats;

    final filteredChats = allChats.chats
        .where(
          (chat) =>
              chat.participant.name.toLowerCase().contains(
                query.toLowerCase(),
              ) ||
              chat.lastMessage.content.toLowerCase().contains(
                query.toLowerCase(),
              ),
        )
        .toList();

    return ChatsResponse(chats: filteredChats, hasMore: false);
  }

  // ========== MOCK DATA ==========
  // Backend developer: Remove these methods when integrating real API.

  ChatsResponse _getMockChats(bool isAdmin) {
    if (isAdmin) {
      return ChatsResponse(
        chats: [
          ChatModel(
            id: 'admin-1',
            participant: const ChatParticipant(
              id: 'admin',
              name: 'EventMaker Admin',
              role: 'admin',
            ),
            lastMessage: MessageModel(
              id: 'm1',
              chatId: 'admin-1',
              senderId: 'admin',
              content: 'Hello, how can we assist you today?',
              createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
              isMe: false,
            ),
            unreadCount: 1,
            isAdminChat: true,
            updatedAt: DateTime.now().subtract(const Duration(minutes: 30)),
          ),
        ],
        hasMore: false,
      );
    }

    return ChatsResponse(
      chats: [
        ChatModel(
          id: '1',
          participant: const ChatParticipant(
            id: 'user-1',
            name: 'Jony Gomes',
            avatarUrl: null,
            isOnline: true,
          ),
          lastMessage: MessageModel(
            id: 'm1',
            chatId: '1',
            senderId: 'user-1',
            content: 'Hi! How are you? 😊',
            createdAt: DateTime.now().subtract(const Duration(hours: 1)),
            isMe: false,
          ),
          unreadCount: 0,
          isAdminChat: false,
          updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
        ),
      ],
      hasMore: false,
    );
  }

  MessagesResponse _getMockMessages(String chatId) {
    final now = DateTime.now();

    if (chatId.startsWith('admin')) {
      return MessagesResponse(
        messages: [
          MessageModel(
            id: '3',
            chatId: chatId,
            senderId: 'current_user',
            content: 'How can I improve my Services?',
            createdAt: now.subtract(const Duration(minutes: 2)),
            isMe: true,
          ),
          MessageModel(
            id: '2',
            chatId: chatId,
            senderId: 'admin',
            content: 'Here are some tips that might help you rest better.',
            createdAt: now.subtract(const Duration(minutes: 5)),
            isMe: false,
          ),
          MessageModel(
            id: '1',
            chatId: chatId,
            senderId: 'current_user',
            content: 'How can I improve my sleep?',
            createdAt: now.subtract(const Duration(minutes: 10)),
            isMe: true,
          ),
        ],
        hasMore: false,
      );
    }

    return MessagesResponse(
      messages: [
        MessageModel(
          id: '1',
          chatId: chatId,
          senderId: 'current_user',
          content:
              'lorem, sed volutpat lacus ullamcorper. Sed hendrerit ullamcorper elit adipiscing urna. Ut ipsum orci libero, consectetur at.',
          createdAt: now.subtract(const Duration(hours: 1)),
          isMe: true,
        ),
      ],
      hasMore: false,
    );
  }
}
