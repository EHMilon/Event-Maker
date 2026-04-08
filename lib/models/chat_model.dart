import 'package:get/get.dart';

/// Chat-related models for backend compatibility.
/// These models provide type-safe data structures for the chat feature.

/// Represents a member in a chat conversation.
class ChatMember {
  final String id;
  final String email;
  final String role;

  const ChatMember({required this.id, required this.email, required this.role});

  factory ChatMember.fromJson(Map<String, dynamic> json) {
    return ChatMember(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'email': email, 'role': role};
  }

  ChatMember copyWith({String? id, String? email, String? role}) {
    return ChatMember(
      id: id ?? this.id,
      email: email ?? this.email,
      role: role ?? this.role,
    );
  }
}

/// Represents a sender of a message.
class MessageSender {
  final String id;
  final String email;
  final String role;

  const MessageSender({
    required this.id,
    required this.email,
    required this.role,
  });

  factory MessageSender.fromJson(Map<String, dynamic> json) {
    return MessageSender(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'email': email, 'role': role};
  }
}

/// Represents a chat conversation/thread.
class ChatModel {
  final String id;
  final bool isGroup;
  final String? name;
  final DateTime createdAt;
  final List<ChatMember> members;
  final ChatMessage? lastMessage;

  const ChatModel({
    required this.id,
    required this.isGroup,
    this.name,
    required this.createdAt,
    required this.members,
    this.lastMessage,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['id'] as String? ?? '',
      isGroup: json['is_group'] as bool? ?? false,
      name: json['name'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      members:
          (json['members'] as List<dynamic>?)
              ?.map((e) => ChatMember.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      lastMessage: json['last_message'] != null
          ? ChatMessage.fromJson(json['last_message'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'is_group': isGroup,
      'name': name,
      'created_at': createdAt.toIso8601String(),
      'members': members.map((e) => e.toJson()).toList(),
      'last_message': lastMessage?.toJson(),
    };
  }

  ChatModel copyWith({
    String? id,
    bool? isGroup,
    String? name,
    DateTime? createdAt,
    List<ChatMember>? members,
    ChatMessage? lastMessage,
  }) {
    return ChatModel(
      id: id ?? this.id,
      isGroup: isGroup ?? this.isGroup,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      members: members ?? this.members,
      lastMessage: lastMessage ?? this.lastMessage,
    );
  }

  /// Get the other participant in a private chat (not the current user)
  ChatMember? getOtherParticipant(String currentUserId) {
    if (isGroup) return null;
    return members.firstWhereOrNull((m) => m.id != currentUserId);
  }

  /// Get display name for the chat (name or other participant's name)
  String getDisplayName(String currentUserId) {
    if (name != null && name!.isNotEmpty) return name!;
    final other = getOtherParticipant(currentUserId);
    return other?.email ?? 'Unknown';
  }
}

/// Represents a single message in a chat.
class ChatMessage {
  final String id;
  final String chatId;
  final MessageSender sender;
  final String content;
  final DateTime createdAt;

  const ChatMessage({
    required this.id,
    required this.chatId,
    required this.sender,
    required this.content,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String? ?? '',
      chatId: json['chat'] as String? ?? '',
      sender: MessageSender.fromJson(
        json['sender'] as Map<String, dynamic>? ?? {},
      ),
      content: json['content'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chat': chatId,
      'sender': sender.toJson(),
      'content': content,
      'created_at': createdAt.toIso8601String(),
    };
  }

  ChatMessage copyWith({
    String? id,
    String? chatId,
    MessageSender? sender,
    String? content,
    DateTime? createdAt,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      sender: sender ?? this.sender,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Formats the message time for display (e.g., "9:41 AM").
  String get formattedTime {
    final hour = createdAt.hour > 12 ? createdAt.hour - 12 : createdAt.hour;
    final period = createdAt.hour >= 12 ? 'PM' : 'AM';
    final minute = createdAt.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  /// Check if this message was sent by the current user
  bool isSentBy(String userId) {
    return sender.id == userId;
  }
}

/// Response model for paginated messages.
class MessagesResponse {
  final List<ChatMessage> messages;
  final bool hasMore;
  final String? nextCursor;

  const MessagesResponse({
    required this.messages,
    required this.hasMore,
    this.nextCursor,
  });

  factory MessagesResponse.fromJson(Map<String, dynamic> json) {
    return MessagesResponse(
      messages:
          (json['messages'] as List<dynamic>?)
              ?.map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
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

  factory ChatsResponse.fromJson(dynamic json) {
    if (json is List) {
      return ChatsResponse(
        chats: json
            .map((e) => ChatModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        hasMore: false,
      );
    }
    if (json is Map<String, dynamic>) {
      return ChatsResponse(
        chats:
            (json['chats'] as List<dynamic>?)
                ?.map((e) => ChatModel.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        hasMore: json['has_more'] as bool? ?? false,
        nextCursor: json['next_cursor'] as String?,
      );
    }
    return const ChatsResponse(chats: [], hasMore: false);
  }
}

// ===== LEGACY MODELS (for backward compatibility with existing UI) =====

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

/// Represents a participant in a chat conversation (legacy model for UI compatibility).
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
}

/// Represents a single message in a chat (legacy model for UI compatibility).
class MessageModel {
  final String id;
  final String chatId;
  final String senderId;
  final String senderEmail;
  final String senderRole;
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
    this.senderEmail = '',
    this.senderRole = '',
    required this.content,
    required this.createdAt,
    this.type = MessageType.text,
    this.isMe = false,
    this.attachmentUrl,
    this.attachmentName,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    // Handle new API format with nested sender
    MessageSender? sender;
    if (json['sender'] != null) {
      sender = MessageSender.fromJson(json['sender'] as Map<String, dynamic>);
    }

    return MessageModel(
      id: json['id'] as String? ?? '',
      chatId: json['chat'] as String? ?? json['chat_id'] as String? ?? '',
      senderId: sender?.id ?? json['sender_id'] as String? ?? '',
      senderEmail: sender?.email ?? json['sender_email'] as String? ?? '',
      senderRole: sender?.role ?? json['sender_role'] as String? ?? '',
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
