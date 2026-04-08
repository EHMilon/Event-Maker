/// Chat-related models for backend compatibility.
/// These models provide type-safe data structures for the chat feature.
library;

/// Represents a chat conversation/thread.
class ChatModel {
  final String id;
  final ChatParticipant participant;
  final MessageModel lastMessage;
  final int unreadCount;
  final bool isAdminChat;
  final DateTime updatedAt;

  const ChatModel({
    required this.id,
    required this.participant,
    required this.lastMessage,
    this.unreadCount = 0,
    this.isAdminChat = false,
    required this.updatedAt,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['id'] as String? ?? '',
      participant: ChatParticipant.fromJson(
        json['participant'] as Map<String, dynamic>? ?? {},
      ),
      lastMessage: MessageModel.fromJson(
        json['lastMessage'] as Map<String, dynamic>? ?? {},
      ),
      unreadCount: json['unread_count'] as int? ?? 0,
      isAdminChat: json['is_admin_chat'] as bool? ?? false,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'participant': participant.toJson(),
      'lastMessage': lastMessage.toJson(),
      'unread_count': unreadCount,
      'is_admin_chat': isAdminChat,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  ChatModel copyWith({
    String? id,
    ChatParticipant? participant,
    MessageModel? lastMessage,
    int? unreadCount,
    bool? isAdminChat,
    DateTime? updatedAt,
  }) {
    return ChatModel(
      id: id ?? this.id,
      participant: participant ?? this.participant,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      isAdminChat: isAdminChat ?? this.isAdminChat,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Represents a participant in a chat conversation.
class ChatParticipant {
  final String id;
  final String name;
  final String? avatarUrl;
  final bool isOnline;
  final String? role;

  const ChatParticipant({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.isOnline = false,
    this.role,
  });

  factory ChatParticipant.fromJson(Map<String, dynamic> json) {
    return ChatParticipant(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown',
      avatarUrl: json['avatar_url'] as String?,
      isOnline: json['is_online'] as bool? ?? false,
      role: json['role'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatar_url': avatarUrl,
      'is_online': isOnline,
      'role': role,
    };
  }

  ChatParticipant copyWith({
    String? id,
    String? name,
    String? avatarUrl,
    bool? isOnline,
    String? role,
  }) {
    return ChatParticipant(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isOnline: isOnline ?? this.isOnline,
      role: role ?? this.role,
    );
  }
}

/// Message type enum for different content types.
enum MessageType {
  text,
  image,
  file,
  system;

  static MessageType fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'image':
        return MessageType.image;
      case 'file':
        return MessageType.file;
      case 'system':
        return MessageType.system;
      default:
        return MessageType.text;
    }
  }

  String toJsonString() {
    return name;
  }
}

/// Represents a single message in a chat.
class MessageModel {
  final String id;
  final String chatId;
  final String senderId;
  final String content;
  final DateTime createdAt;
  final MessageType type;
  final bool isMe;
  final String? attachmentUrl;
  final String? attachmentName;

  const MessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.content,
    required this.createdAt,
    this.type = MessageType.text,
    this.isMe = false,
    this.attachmentUrl,
    this.attachmentName,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String? ?? '',
      chatId: json['chat_id'] as String? ?? '',
      senderId: json['sender_id'] as String? ?? '',
      content: json['content'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      type: MessageType.fromString(json['type'] as String?),
      isMe: json['is_me'] as bool? ?? false,
      attachmentUrl: json['attachment_url'] as String?,
      attachmentName: json['attachment_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chat_id': chatId,
      'sender_id': senderId,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'type': type.toJsonString(),
      'is_me': isMe,
      'attachment_url': attachmentUrl,
      'attachment_name': attachmentName,
    };
  }

  MessageModel copyWith({
    String? id,
    String? chatId,
    String? senderId,
    String? content,
    DateTime? createdAt,
    MessageType? type,
    bool? isMe,
    String? attachmentUrl,
    String? attachmentName,
  }) {
    return MessageModel(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      type: type ?? this.type,
      isMe: isMe ?? this.isMe,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      attachmentName: attachmentName ?? this.attachmentName,
    );
  }

  /// Formats the message time for display (e.g., "9:41 AM").
  String get formattedTime {
    final hour = createdAt.hour > 12 ? createdAt.hour - 12 : createdAt.hour;
    final period = createdAt.hour >= 12 ? 'PM' : 'AM';
    final minute = createdAt.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }
}

/// Response model for paginated messages.
class MessagesResponse {
  final List<MessageModel> messages;
  final bool hasMore;
  final String? nextCursor;

  const MessagesResponse({
    required this.messages,
    required this.hasMore,
    this.nextCursor,
  });

  factory MessagesResponse.fromJson(Map<String, dynamic> json) {
    return MessagesResponse(
      messages: (json['messages'] as List<dynamic>?)
              ?.map((e) => MessageModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      hasMore: json['has_more'] as bool? ?? false,
      nextCursor: json['next_cursor'] as String?,
    );
  }
}

/// Response model for paginated chat list.
class ChatsResponse {
  final List<ChatModel> chats;
  final bool hasMore;
  final String? nextCursor;

  const ChatsResponse({
    required this.chats,
    required this.hasMore,
    this.nextCursor,
  });

  factory ChatsResponse.fromJson(Map<String, dynamic> json) {
    return ChatsResponse(
      chats: (json['chats'] as List<dynamic>?)
              ?.map((e) => ChatModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      hasMore: json['has_more'] as bool? ?? false,
      nextCursor: json['next_cursor'] as String?,
    );
  }
}
