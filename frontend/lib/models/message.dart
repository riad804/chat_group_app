import 'package:equatable/equatable.dart';

class Message extends Equatable {
  final String id;
  final String username;
  final String message;
  final DateTime timestamp;

  const Message({
    required this.id,
    required this.username,
    required this.message,
    required this.timestamp,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      username: json['username'] as String,
      message: json['message'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  @override
  List<Object> get props => [id, username, message, timestamp];
}
