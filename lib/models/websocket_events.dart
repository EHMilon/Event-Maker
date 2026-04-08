/// WebSocket events for real-time chat communication.

/// Base class for all WebSocket events.
abstract class WebSocketEvent {
  final String type;
  final DateTime timestamp;

  WebSocketEvent({required this.type}) : timestamp = DateTime.now();

  Map<String, dynamic> toJson();
}

/// Event sent when a new message is received.
class MessageReceivedEvent extends WebSocketEvent {
  final String chatId;
  final String messageId;
  final String senderId;
  final String senderName;
  final String content;
  final DateTime createdAt;

  MessageReceivedEvent({
    required this.chatId,
    required this.messageId,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.createdAt,
  }) : super(type: 'message_received');

  factory MessageReceivedEvent.fromJson(Map<String, dynamic> json) {
    return MessageReceivedEvent(
      chatId: json['chat_id'] as String? ?? '',
      messageId: json['message_id'] as String? ?? json['id'] as String? ?? '',
      senderId: json['sender_id'] as String? ?? '',
      senderName: json['sender_name'] as String? ?? 'Unknown',
      content: json['content'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'chat_id': chatId,
      'message_id': messageId,
      'sender_id': senderId,
      'sender_name': senderName,
      'content': content,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

/// Event sent when connection is established.
class ConnectedEvent extends WebSocketEvent {
  final String chatId;

  ConnectedEvent({required this.chatId}) : super(type: 'connected');

  @override
  Map<String, dynamic> toJson() {
    return {'type': type, 'chat_id': chatId};
  }
}

/// Event sent when connection is lost.
class DisconnectedEvent extends WebSocketEvent {
  final String? reason;

  DisconnectedEvent({this.reason}) : super(type: 'disconnected');

  @override
  Map<String, dynamic> toJson() {
    return {'type': type, if (reason != null) 'reason': reason};
  }
}

/// Event sent when an error occurs.
class ErrorEvent extends WebSocketEvent {
  final String message;
  final String? code;

  ErrorEvent({required this.message, this.code}) : super(type: 'error');

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'message': message,
      if (code != null) 'code': code,
    };
  }
}

/// Event sent when a message is sent successfully.
class MessageSentEvent extends WebSocketEvent {
  final String messageId;
  final String chatId;
  final String content;

  MessageSentEvent({
    required this.messageId,
    required this.chatId,
    required this.content,
  }) : super(type: 'message_sent');

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'message_id': messageId,
      'chat_id': chatId,
      'content': content,
    };
  }
}

/// Event for typing indicator.
class TypingEvent extends WebSocketEvent {
  final String chatId;
  final String userId;
  final String userName;
  final bool isTyping;

  TypingEvent({
    required this.chatId,
    required this.userId,
    required this.userName,
    required this.isTyping,
  }) : super(type: 'typing');

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'chat_id': chatId,
      'user_id': userId,
      'user_name': userName,
      'is_typing': isTyping,
    };
  }
}
