import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:event_maker/models/chat_model.dart';
import 'package:event_maker/services/websocket_service.dart';
import 'package:event_maker/views/chats/chat_repository.dart';

/// Controller for the chat detail / conversation screen.
/// Uses [ChatRepository] for REST API and [WebSocketService] for real-time messaging.
class ChatDetailController extends GetxController {
  final ChatRepository _repository = ChatRepository();
  WebSocketService? _wsService;
  Timer? _pollingTimer;

  final isLoading = true.obs;
  final isSending = false.obs;
  final isConnected = false.obs;
  final messageText = ''.obs;
  final hasError = false.obs;
  String? errorMessage;

  // Messages list from API
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

  // Current user ID for determining message alignment
  String? currentUserId;
  String? authToken;

  @override
  void onInit() {
    super.onInit();
    _parseArguments();
    _initializeWebSocket();
    loadMessages();
    _startPolling();
  }

  @override
  void onClose() {
    _wsService?.disconnect();
    _wsService?.dispose();
    _pollingTimer?.cancel();
    super.onClose();
  }

  /// Start periodic polling to refresh messages as backup
  void _startPolling() {
    // Refresh messages every 3 seconds as backup
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _refreshMessages();
    });
  }

  /// Refresh messages from API
  Future<void> _refreshMessages() async {
    try {
      final fetchedMessages = await _repository.fetchMessages(chatId);
      
      // Always update the messages list with fresh data
      messages.value = fetchedMessages;
    } catch (e) {
      // Silently fail polling
    }
  }

  /// Initialize WebSocket connection for real-time messaging
  Future<void> _initializeWebSocket() async {
    // Get auth token from storage
    final prefs = await SharedPreferences.getInstance();
    authToken = prefs.getString('access_token');

    if (authToken == null || authToken!.isEmpty) {
      debugPrint('WebSocket: No auth token found');
      return;
    }

    debugPrint('WebSocket: Connecting to $chatId');

    _wsService = WebSocketService(
      onMessageReceived: _handleWebSocketMessage,
      onConnected: (connected) {
        isConnected.value = connected;
        debugPrint('WebSocket: Connected = $connected');
      },
      onDisconnected: (connected) {
        isConnected.value = false;
        debugPrint('WebSocket: Disconnected');
      },
      onError: (error) {
        hasError.value = true;
        errorMessage = error;
        debugPrint('WebSocket Error: $error');
      },
    );

    // Connect to WebSocket
    await _wsService!.connect(chatId, authToken!);
  }

  /// Handle incoming WebSocket messages
  void _handleWebSocketMessage(dynamic data) {
    try {
      Map<String, dynamic> json;
      if (data is String) {
        json = jsonDecode(data) as Map<String, dynamic>;
      } else {
        json = data as Map<String, dynamic>;
      }

      // Check the type field
      final type = json['type'] as String?;

      // Accept messages with any type except error/ping/pong
      if (type == 'error' || type == 'ping' || type == 'pong') {
        return;
      }
      
      // Try multiple field names for message ID
      final messageId = json['message_id'] as String? ?? 
                       json['id'] as String? ?? 
                       json['msg_id'] as String?;
      
      // Try multiple field names for content
      final content = json['content'] as String? ?? 
                     json['text'] as String? ?? 
                     json['message'] as String? ?? '';
      
      if (content.isEmpty) return;

      // Try multiple field names for sender
      final senderId = json['sender_id'] as String? ?? 
                      json['from'] as String? ?? 
                      json['user_id'] as String? ?? '';
      
      final senderName = json['sender_name'] as String? ?? 
                        json['sender'] as String? ?? 
                        json['name'] as String?;
      
      final senderEmail = json['sender_email'] as String? ?? '';
      final senderRole = json['sender_role'] as String? ?? '';
      final senderAvatar = json['sender_avatar'] as String?;

      // Try multiple formats for timestamp
      DateTime createdAt;
      try {
        final timestamp = json['created_at'] ?? json['timestamp'] ?? json['time'];
        if (timestamp is String) {
          createdAt = DateTime.parse(timestamp);
        } else if (timestamp is int) {
          createdAt = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
        } else {
          createdAt = DateTime.now();
        }
      } catch (e) {
        createdAt = DateTime.now();
      }

      // Create message object
      final message = ChatMessage(
        id: messageId ?? 'ws_${DateTime.now().millisecondsSinceEpoch}',
        chatId: chatId,
        sender: MessageSender(
          id: senderId,
          email: senderEmail,
          role: senderRole,
          fullName: senderName,
          avatar: senderAvatar,
        ),
        content: content,
        createdAt: createdAt,
      );

      // Add message if not already in list
      if (!messages.any((m) => m.id == message.id)) {
        messages.insert(0, message);
      }
    } catch (e) {
      // Silently handle parse errors
    }
  }

  /// Parses navigation arguments.
  void _parseArguments() {
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    chatId = args['id'] as String? ?? '';
    chatName = args['name'] as String? ?? 'Unknown';
    final providedImage = args['image'] as String?;
    chatImage = (providedImage != null && providedImage.isNotEmpty)
        ? providedImage
        : 'assets/icons/icon.svg';
    isAdminChat = args['isAdmin'] as bool? ?? false;
    
    debugPrint('ChatDetailController: chatId=$chatId, chatName=$chatName');
  }

  /// Get current user ID from preferences
  Future<String?> _getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }

  /// Loads messages for the current chat.
  Future<void> loadMessages() async {
    isLoading.value = true;
    hasError.value = false;
    errorMessage = null;

    try {
      currentUserId = await _getCurrentUserId();
      final fetchedMessages = await _repository.fetchMessages(chatId);
      messages.value = fetchedMessages;

      if (fetchedMessages.isNotEmpty) {
        await _repository.markAsRead(chatId);
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
      final fetchedMessages = await _repository.fetchMessages(chatId);
      messages.addAll(fetchedMessages);
      hasMoreMessages = false;
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
  /// Uses REST API for sending (more reliable).
  /// Note: We only use REST API, WebSocket is for receiving only.
  Future<void> sendMessage({String? overrideText}) async {
    final composed = (overrideText ?? messageText.value).trim();
    if (composed.isEmpty || isSending.value) return;

    isSending.value = true;

    try {
      // Use REST API for reliable sending
      final sentMessage = await _repository.sendMessage(
        chatId: chatId,
        content: composed,
      );

      if (sentMessage != null) {
        // Add to list immediately with deduplication
        if (!messages.any((m) => m.id == sentMessage.id)) {
          messages.insert(0, sentMessage);
        }
      }
      messageText.value = '';
      
      // Note: We do NOT send via WebSocket to avoid duplicate messages
      // The server will broadcast via WebSocket to other clients
      // and we'll receive it in _handleWebSocketMessage
    } catch (e) {
      hasError.value = true;
      errorMessage = 'Failed to send message: $e';
    } finally {
      isSending.value = false;
    }
  }
}
