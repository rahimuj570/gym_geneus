// lib/app/data/models/chat_models.dart

class ChatMessage {
  final int id;
  final String sender; // "user" or "ai"
  final String message;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.sender,
    required this.message,
    required this.timestamp,
  });

  bool get isUser => sender == "user";

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      sender: json['sender'],
      message: json['message'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

class ChatConversation {
  final int id;
  final String userId;
  final DateTime createdAt;
  final List<ChatMessage> messages;

  ChatConversation({
    required this.id,
    required this.userId,
    required this.createdAt,
    required this.messages,
  });

  factory ChatConversation.fromJson(Map<String, dynamic> json) {
    return ChatConversation(
      id: json['id'],
      userId: json['user'],
      createdAt: DateTime.parse(json['created_at']),
      messages: (json['messages'] as List)
          .map((m) => ChatMessage.fromJson(m))
          .toList(),
    );
  }
}
