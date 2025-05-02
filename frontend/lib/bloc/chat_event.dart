import 'package:equatable/equatable.dart';
import '../models/message.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object> get props => [];
}

class JoinChat extends ChatEvent {
  final String username;

  const JoinChat(this.username);

  @override
  List<Object> get props => [username];
}

class SendMessage extends ChatEvent {
  final String message;

  const SendMessage(this.message);

  @override
  List<Object> get props => [message];
}

class MessageReceived extends ChatEvent {
  final Message message;

  const MessageReceived(this.message);

  @override
  List<Object> get props => [message];
}

class UserJoined extends ChatEvent {
  final String username;
  final List<String> connectedUsers;

  const UserJoined(this.username, this.connectedUsers);

  @override
  List<Object> get props => [username, connectedUsers];
}

class UserLeft extends ChatEvent {
  final String username;
  final List<String> connectedUsers;

  const UserLeft(this.username, this.connectedUsers);

  @override
  List<Object> get props => [username, connectedUsers];
}

class SetTypingStatus extends ChatEvent {
  final String username;
  final bool isTyping;

  const SetTypingStatus(this.username, this.isTyping);

  @override
  List<Object> get props => [username, isTyping];
}
