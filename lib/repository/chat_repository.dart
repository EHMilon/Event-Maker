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
    return MessageModel(
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
      participant: ChatParticipant(
        id: participantId,
        name: 'New Chat',
      ),
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
        .where((chat) =>
            chat.participant.name.toLowerCase().contains(query.toLowerCase()) ||
            chat.lastMessage.content.toLowerCase().contains(query.toLowerCase()))
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
