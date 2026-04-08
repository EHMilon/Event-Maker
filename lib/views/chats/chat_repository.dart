import 'dart:async';
import 'package:event_maker/constants/api_constant.dart';
import 'package:event_maker/models/chat_model.dart';
import 'package:event_maker/services/api_service.dart';

/// Repository for chat-related data operations with backend API integration.
///
/// Endpoints:
/// - GET  /api/chats?chat_type=normal|admin    → List chats
/// - GET  /api/chats/{chatId}/messages        → List messages
/// - POST /api/chats/{chatId}/messages        → Send message
class ChatRepository {
  final ApiService _apiService = ApiService();

  /// Fetches the list of chats for the current user.
  ///
  /// Backend: GET /api/chats?chat_type=normal|admin
  ///
  /// [chatType] - Filter by chat type: 'normal' for customer/provider chats, 'admin' for admin chats
  Future<List<ChatModel>> fetchChats({String? chatType}) async {
    try {
      String endpoint = ApiConstant.chats;

      // Add chat_type query param if provided
      if (chatType != null && chatType.isNotEmpty) {
        endpoint += '?${ApiConstant.chatTypeParam}=$chatType';
      }

      final response = await _apiService.get(endpoint);

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

  /// Creates or fetches a private admin chat.
  /// If a chat already exists, returns the existing chat.
  ///
  /// Backend: POST /api/chats/private-admin
  Future<ChatModel?> createOrGetAdminChat() async {
    try {
      final response = await _apiService.post(ApiConstant.chatsPrivateAdmin);

      if (response is Map<String, dynamic>) {
        return ChatModel.fromJson(response);
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Fetches normal (customer/provider) chats.
  ///
  /// Backend: GET /api/chats?chat_type=normal
  Future<List<ChatModel>> fetchNormalChats() async {
    return fetchChats(chatType: ApiConstant.chatTypeNormal);
  }

  /// Fetches admin chats.
  ///
  /// Backend: GET /api/chats?chat_type=admin
  Future<List<ChatModel>> fetchAdminChats() async {
    return fetchChats(chatType: ApiConstant.chatTypeAdmin);
  }

  /// Fetches messages for a specific chat.
  ///
  /// Backend: GET /api/chats/{chatId}/messages
  ///
  /// Note: API returns messages newest-first, so we reverse to oldest-first
  /// for proper display order (oldest at bottom, newest at top in ListView).
  Future<List<ChatMessage>> fetchMessages(String chatId) async {
    try {
      final response = await _apiService.get(ApiConstant.chatMessages(chatId));

      if (response is List) {
        final messages = response
            .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
            .toList();
        // Reverse to get oldest-first for proper message order
        return messages.reversed.toList();
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
  ///
  /// Response format: { "success": true, "data": ChatMessage }
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
        // Check for wrapped response format: { success: true, data: {...} }
        if (response.containsKey('data')) {
          final data = response['data'];
          if (data is Map<String, dynamic>) {
            return ChatMessage.fromJson(data);
          }
        }
        // Direct response format
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
