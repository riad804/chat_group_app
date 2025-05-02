import 'package:equatable/equatable.dart';
import '../models/message.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatConnected extends ChatState {
  final String username;
  final List<Message> messages;
  final List<String> connectedUsers;
  final Map<String, bool> typingUsers;

  const ChatConnected({
    required this.username,
    required this.messages,
    required this.connectedUsers,
    required this.typingUsers,
  });

  ChatConnected copyWith({
    String? username,
    List<Message>? messages,
    List<String>? connectedUsers,
    Map<String, bool>? typingUsers,
  }) {
    return ChatConnected(
      username: username ?? this.username,
      messages: messages ?? this.messages,
      connectedUsers: connectedUsers ?? this.connectedUsers,
      typingUsers: typingUsers ?? this.typingUsers,
    );
  }

  @override
  List<Object> get props => [username, messages, connectedUsers, typingUsers];
}

class ChatError extends ChatState {
  final String message;

  const ChatError(this.message);

  @override
  List<Object> get props => [message];
}
