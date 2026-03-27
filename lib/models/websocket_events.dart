/// WebSocket event models for real-time chat communication.
///
/// Backend developer: These models define the contract between
/// client and server. Ensure your WebSocket server sends/receives
/// events matching these structures.
///
/// Event flow:
/// 1. Client connects and sends [AuthEvent] with token
/// 2. Server responds with [AuthenticatedEvent]
/// 3. Real-time events flow (messages, typing, presence, etc.)

import 'package:event_maker/models/chat_model.dart';
import 'package:event_maker/constants/api_constant.dart';

/// Base class for all WebSocket events.
abstract class WsEvent {
  /// The event type (matches [WsEventType] constants)
  String get type;

  /// Convert event to JSON for sending to server
  Map<String, dynamic> toJson();

  /// Factory to create event from server response
  static WsEvent fromJson(Map<String, dynamic> json) {
    final eventType = json['type'] as String? ?? '';

    switch (eventType) {
      case WsEventType.authenticated:
        return AuthenticatedEvent.fromJson(json);
      case WsEventType.messageSent:
        return MessageSentEvent.fromJson(json);
      case WsEventType.messageReceived:
        return MessageReceivedEvent.fromJson(json);
      case WsEventType.messageDelivered:
        return MessageDeliveredEvent.fromJson(json);
      case WsEventType.messageRead:
        return MessageReadEvent.fromJson(json);
      case WsEventType.typingStart:
      case WsEventType.typingStop:
        return TypingEvent.fromJson(json);
      case WsEventType.userOnline:
      case WsEventType.userOffline:
      case WsEventType.userStatus:
        return UserPresenceEvent.fromJson(json);
      case WsEventType.chatCreated:
        return ChatCreatedEvent.fromJson(json);
      case WsEventType.chatUpdated:
        return ChatUpdatedEvent.fromJson(json);
      case WsEventType.error:
        return ErrorEvent.fromJson(json);
      case WsEventType.pong:
        return PongEvent.fromJson(json);
      default:
        return UnknownEvent.fromJson(json);
    }
  }
}

// ===== CONNECTION EVENTS =====

/// Event sent by client to authenticate WebSocket connection.
///
/// Backend developer: Send this immediately after WebSocket connects.
///
/// ```json
/// {
///   "type": "authenticate",
///   "token": "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
/// }
/// ```
class AuthEvent extends WsEvent {
  final String token;

  AuthEvent({required this.token});

  @override
  String get type => WsEventType.authenticate;

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'token': token,
      };
}

/// Server response confirming successful authentication.
///
/// Backend developer: Respond with this after validating token.
///
/// ```json
/// {
///   "type": "authenticated",
///   "user_id": "user-123",
///   "status": "online"
/// }
/// ```
class AuthenticatedEvent extends WsEvent {
  final String userId;
  final String status;

  AuthenticatedEvent({
    required this.userId,
    this.status = 'online',
  });

  @override
  String get type => WsEventType.authenticated;

  factory AuthenticatedEvent.fromJson(Map<String, dynamic> json) {
    return AuthenticatedEvent(
      userId: json['user_id'] as String? ?? '',
      status: json['status'] as String? ?? 'online',
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'user_id': userId,
        'status': status,
      };
}

/// Ping event for heartbeat/connection health.
class PingEvent extends WsEvent {
  @override
  String get type => WsEventType.ping;

  @override
  Map<String, dynamic> toJson() => {'type': type};
}

/// Pong response from server.
class PongEvent extends WsEvent {
  final DateTime timestamp;

  PongEvent({DateTime? timestamp}) : timestamp = timestamp ?? DateTime.now();

  @override
  String get type => WsEventType.pong;

  factory PongEvent.fromJson(Map<String, dynamic> json) {
    return PongEvent(
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'timestamp': timestamp.toIso8601String(),
      };
}

// ===== MESSAGE EVENTS =====

/// Event for sending a new message.
///
/// Backend developer: Client sends this, server responds with [MessageSentEvent].
///
/// ```json
/// {
///   "type": "message:send",
///   "chat_id": "chat-123",
///   "content": "Hello!",
///   "message_type": "text",
///   "temp_id": "temp-456"  // Client-generated for optimistic UI
/// }
/// ```
class SendMessageEvent extends WsEvent {
  final String chatId;
  final String content;
  final MessageType messageType;
  final String tempId;
  final String? attachmentUrl;
  final String? attachmentName;

  SendMessageEvent({
    required this.chatId,
    required this.content,
    this.messageType = MessageType.text,
    String? tempId,
    this.attachmentUrl,
    this.attachmentName,
  }) : tempId = tempId ?? 'temp-${DateTime.now().millisecondsSinceEpoch}';

  @override
  String get type => WsEventType.messageSend;

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'chat_id': chatId,
        'content': content,
        'message_type': messageType.toJsonString(),
        'temp_id': tempId,
        if (attachmentUrl != null) 'attachment_url': attachmentUrl,
        if (attachmentName != null) 'attachment_name': attachmentName,
      };
}

/// Server confirmation that message was sent.
///
/// Backend developer: Respond with the created message including server-assigned ID.
///
/// ```json
/// {
///   "type": "message:sent",
///   "message": { ... },
///   "temp_id": "temp-456"  // Echo back for client to update optimistic message
/// }
/// ```
class MessageSentEvent extends WsEvent {
  final MessageModel message;
  final String tempId;

  MessageSentEvent({
    required this.message,
    required this.tempId,
  });

  @override
  String get type => WsEventType.messageSent;

  factory MessageSentEvent.fromJson(Map<String, dynamic> json) {
    return MessageSentEvent(
      message: MessageModel.fromJson(json['message'] as Map<String, dynamic>? ?? {}),
      tempId: json['temp_id'] as String? ?? '',
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'message': message.toJson(),
        'temp_id': tempId,
      };
}

/// Event received when another user sends a message.
///
/// Backend developer: Push this to all chat participants.
///
/// ```json
/// {
///   "type": "message:received",
///   "message": { ... }
/// }
/// ```
class MessageReceivedEvent extends WsEvent {
  final MessageModel message;

  MessageReceivedEvent({required this.message});

  @override
  String get type => WsEventType.messageReceived;

  factory MessageReceivedEvent.fromJson(Map<String, dynamic> json) {
    return MessageReceivedEvent(
      message: MessageModel.fromJson(json['message'] as Map<String, dynamic>? ?? {}),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'message': message.toJson(),
      };
}

/// Message delivery confirmation.
///
/// Backend developer: Send when message is delivered to user's device.
///
/// ```json
/// {
///   "type": "message:delivered",
///   "message_id": "msg-123",
///   "chat_id": "chat-456",
///   "delivered_at": "2024-01-15T10:30:00Z"
/// }
/// ```
class MessageDeliveredEvent extends WsEvent {
  final String messageId;
  final String chatId;
  final DateTime deliveredAt;

  MessageDeliveredEvent({
    required this.messageId,
    required this.chatId,
    DateTime? deliveredAt,
  }) : deliveredAt = deliveredAt ?? DateTime.now();

  @override
  String get type => WsEventType.messageDelivered;

  factory MessageDeliveredEvent.fromJson(Map<String, dynamic> json) {
    return MessageDeliveredEvent(
      messageId: json['message_id'] as String? ?? '',
      chatId: json['chat_id'] as String? ?? '',
      deliveredAt: json['delivered_at'] != null
          ? DateTime.parse(json['delivered_at'] as String)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'message_id': messageId,
        'chat_id': chatId,
        'delivered_at': deliveredAt.toIso8601String(),
      };
}

/// Message read confirmation.
///
/// Backend developer: Send when user opens/reads a message.
///
/// ```json
/// {
///   "type": "message:read",
///   "message_id": "msg-123",
///   "chat_id": "chat-456",
///   "read_by": "user-789",
///   "read_at": "2024-01-15T10:35:00Z"
/// }
/// ```
class MessageReadEvent extends WsEvent {
  final String messageId;
  final String chatId;
  final String readBy;
  final DateTime readAt;

  MessageReadEvent({
    required this.messageId,
    required this.chatId,
    required this.readBy,
    DateTime? readAt,
  }) : readAt = readAt ?? DateTime.now();

  @override
  String get type => WsEventType.messageRead;

  factory MessageReadEvent.fromJson(Map<String, dynamic> json) {
    return MessageReadEvent(
      messageId: json['message_id'] as String? ?? '',
      chatId: json['chat_id'] as String? ?? '',
      readBy: json['read_by'] as String? ?? '',
      readAt: json['read_at'] != null
          ? DateTime.parse(json['read_at'] as String)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'message_id': messageId,
        'chat_id': chatId,
        'read_by': readBy,
        'read_at': readAt.toIso8601String(),
      };
}

// ===== TYPING EVENTS =====

/// User typing indicator event.
///
/// Backend developer: Broadcast to chat participants when user starts/stops typing.
///
/// ```json
/// {
///   "type": "typing:start",  // or "typing:stop"
///   "chat_id": "chat-123",
///   "user_id": "user-456"
/// }
/// ```
class TypingEvent extends WsEvent {
  final String chatId;
  final String userId;
  final bool isTyping;

  TypingEvent({
    required this.chatId,
    required this.userId,
    required this.isTyping,
  });

  @override
  String get type => isTyping ? WsEventType.typingStart : WsEventType.typingStop;

  factory TypingEvent.fromJson(Map<String, dynamic> json) {
    final eventType = json['type'] as String? ?? '';
    return TypingEvent(
      chatId: json['chat_id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      isTyping: eventType == WsEventType.typingStart,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'chat_id': chatId,
        'user_id': userId,
      };
}

// ===== PRESENCE EVENTS =====

/// User online/offline status event.
///
/// Backend developer: Broadcast when user's presence changes.
///
/// ```json
/// {
///   "type": "user:online",  // or "user:offline", "user:status"
///   "user_id": "user-123",
///   "status": "online",  // "online", "offline", "away"
///   "last_seen": "2024-01-15T10:30:00Z"
/// }
/// ```
class UserPresenceEvent extends WsEvent {
  final String userId;
  final String status;
  final DateTime? lastSeen;

  UserPresenceEvent({
    required this.userId,
    required this.status,
    this.lastSeen,
  });

  bool get isOnline => status == 'online';

  @override
  String get type {
    switch (status) {
      case 'online':
        return WsEventType.userOnline;
      case 'offline':
        return WsEventType.userOffline;
      default:
        return WsEventType.userStatus;
    }
  }

  factory UserPresenceEvent.fromJson(Map<String, dynamic> json) {
    final eventType = json['type'] as String? ?? '';
    String status = json['status'] as String? ?? 'offline';
    
    // Infer status from event type if not provided
    if (json['status'] == null) {
      if (eventType == WsEventType.userOnline) {
        status = 'online';
      } else if (eventType == WsEventType.userOffline) {
        status = 'offline';
      }
    }

    return UserPresenceEvent(
      userId: json['user_id'] as String? ?? '',
      status: status,
      lastSeen: json['last_seen'] != null
          ? DateTime.parse(json['last_seen'] as String)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'user_id': userId,
        'status': status,
        if (lastSeen != null) 'last_seen': lastSeen!.toIso8601String(),
      };
}

// ===== CHAT EVENTS =====

/// New chat created event.
///
/// Backend developer: Broadcast to chat participants when a new chat is created.
///
/// ```json
/// {
///   "type": "chat:created",
///   "chat": { ... }
/// }
/// ```
class ChatCreatedEvent extends WsEvent {
  final ChatModel chat;

  ChatCreatedEvent({required this.chat});

  @override
  String get type => WsEventType.chatCreated;

  factory ChatCreatedEvent.fromJson(Map<String, dynamic> json) {
    return ChatCreatedEvent(
      chat: ChatModel.fromJson(json['chat'] as Map<String, dynamic>? ?? {}),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'chat': chat.toJson(),
      };
}

/// Chat updated event (last message, unread count, etc.).
///
/// Backend developer: Broadcast when chat metadata changes.
///
/// ```json
/// {
///   "type": "chat:updated",
///   "chat_id": "chat-123",
///   "updates": {
///     "last_message": { ... },
///     "unread_count": 5
///   }
/// }
/// ```
class ChatUpdatedEvent extends WsEvent {
  final String chatId;
  final Map<String, dynamic> updates;

  ChatUpdatedEvent({
    required this.chatId,
    required this.updates,
  });

  /// Get last message if included in updates
  MessageModel? get lastMessage {
    if (updates['last_message'] == null) return null;
    return MessageModel.fromJson(
      updates['last_message'] as Map<String, dynamic>,
    );
  }

  /// Get unread count if included in updates
  int get unreadCount => updates['unread_count'] as int? ?? 0;

  @override
  String get type => WsEventType.chatUpdated;

  factory ChatUpdatedEvent.fromJson(Map<String, dynamic> json) {
    return ChatUpdatedEvent(
      chatId: json['chat_id'] as String? ?? '',
      updates: json['updates'] as Map<String, dynamic>? ?? {},
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'chat_id': chatId,
        'updates': updates,
      };
}

// ===== ERROR EVENTS =====

/// Error event from server.
///
/// Backend developer: Send this when an operation fails.
///
/// ```json
/// {
///   "type": "error",
///   "code": "MESSAGE_SEND_FAILED",
///   "message": "Chat not found",
///   "details": { ... }
/// }
/// ```
class ErrorEvent extends WsEvent {
  final String code;
  final String message;
  final Map<String, dynamic>? details;

  ErrorEvent({
    required this.code,
    required this.message,
    this.details,
  });

  @override
  String get type => WsEventType.error;

  factory ErrorEvent.fromJson(Map<String, dynamic> json) {
    return ErrorEvent(
      code: json['code'] as String? ?? 'UNKNOWN_ERROR',
      message: json['message'] as String? ?? 'An error occurred',
      details: json['details'] as Map<String, dynamic>?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'code': code,
        'message': message,
        if (details != null) 'details': details,
      };
}

/// Unknown/unhandled event type.
class UnknownEvent extends WsEvent {
  final Map<String, dynamic> rawData;

  UnknownEvent({required this.rawData});

  @override
  String get type => rawData['type'] as String? ?? 'unknown';

  factory UnknownEvent.fromJson(Map<String, dynamic> json) {
    return UnknownEvent(rawData: json);
  }

  @override
  Map<String, dynamic> toJson() => rawData;
}

// ===== MARK AS READ EVENT =====

/// Event to mark messages as read in a chat.
///
/// Backend developer: Client sends this, server broadcasts [MessageReadEvent].
///
/// ```json
/// {
///   "type": "message:read",
///   "chat_id": "chat-123",
///   "message_id": "msg-456"  // Last message read
/// }
/// ```
class MarkAsReadEvent extends WsEvent {
  final String chatId;
  final String? lastMessageId;

  MarkAsReadEvent({
    required this.chatId,
    this.lastMessageId,
  });

  @override
  String get type => WsEventType.messageRead;

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'chat_id': chatId,
        if (lastMessageId != null) 'message_id': lastMessageId,
      };
}
