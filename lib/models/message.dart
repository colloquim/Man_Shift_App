// models/message.dart

class Message {
  final String text;
  final String sender; // "user" or "ai"
  final DateTime timestamp;
  final String type; // e.g., "text", "disclaimer", "system"

  Message({
    required this.text,
    required this.sender,
    DateTime? timestamp,
    this.type = "text",
  }) : timestamp = timestamp ?? DateTime.now();

  // Optional: convert to/from JSON if you want to store messages locally
  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'sender': sender,
      'timestamp': timestamp.toIso8601String(),
      'type': type,
    };
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      text: json['text'],
      sender: json['sender'],
      timestamp: DateTime.parse(json['timestamp']),
      type: json['type'] ?? "text",
    );
  }
}
