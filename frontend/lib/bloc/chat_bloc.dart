import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/socket_service.dart';
import 'chat_event.dart';
import 'chat_state.dart';
import '../models/message.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final SocketService _socketService;
  Timer? _typingTimer;

  ChatBloc(this._socketService) : super(ChatInitial()) {
    on<JoinChat>(_onJoinChat);
    on<SendMessage>(_onSendMessage);
    on<MessageReceived>(_onMessageReceived);
    on<UserJoined>(_onUserJoined);
    on<UserLeft>(_onUserLeft);
    on<SetTypingStatus>(_onSetTypingStatus);

    _setupSocketListeners();
  }

  void _setupSocketListeners() {
    _socketService.onNewMessage = (data) {
      add(MessageReceived(Message.fromJson(data)));
    };

    _socketService.onUserJoined = (data) {
      add(UserJoined(
        data['username'] as String,
        List<String>.from(data['connectedUsers'] as List),
      ));
    };

    _socketService.onUserLeft = (data) {
      add(UserLeft(
        data['username'] as String,
        List<String>.from(data['connectedUsers'] as List),
      ));
    };

    _socketService.onUserTyping = (data) {
      add(SetTypingStatus(
        data['username'] as String,
        data['isTyping'] as bool,
      ));
    };
  }

  void _onJoinChat(JoinChat event, Emitter<ChatState> emit) {
    emit(ChatLoading());
    _socketService.connect();
    _socketService.joinChat(event.username);
    emit(ChatConnected(
      username: event.username,
      messages: const [],
      connectedUsers: const [],
      typingUsers: const {},
    ));
  }

  void _onSendMessage(SendMessage event, Emitter<ChatState> emit) {
    if (state is ChatConnected) {
      _socketService.sendMessage(event.message);
    }
  }

  void _onMessageReceived(MessageReceived event, Emitter<ChatState> emit) {
    if (state is ChatConnected) {
      final currentState = state as ChatConnected;
      emit(currentState.copyWith(
        messages: List.from(currentState.messages)..add(event.message),
      ));
    }
  }

  void _onUserJoined(UserJoined event, Emitter<ChatState> emit) {
    if (state is ChatConnected) {
      final currentState = state as ChatConnected;
      emit(currentState.copyWith(
        connectedUsers: event.connectedUsers,
      ));
    }
  }

  void _onUserLeft(UserLeft event, Emitter<ChatState> emit) {
    if (state is ChatConnected) {
      final currentState = state as ChatConnected;
      emit(currentState.copyWith(
        connectedUsers: event.connectedUsers,
      ));
    }
  }

  void _onSetTypingStatus(SetTypingStatus event, Emitter<ChatState> emit) {
    if (state is ChatConnected) {
      final currentState = state as ChatConnected;
      final typingUsers = Map<String, bool>.from(currentState.typingUsers);
      if (event.isTyping) {
        typingUsers[event.username] = true;
      } else {
        typingUsers.remove(event.username);
      }
      emit(currentState.copyWith(typingUsers: typingUsers));
    }
  }

  void startTyping() {
    if (state is ChatConnected) {
      _typingTimer?.cancel();
      _socketService.sendTypingStatus(true);
      _typingTimer = Timer(const Duration(milliseconds: 300), () {
        _socketService.sendTypingStatus(false);
      });
    }
  }

  @override
  Future<void> close() {
    _typingTimer?.cancel();
    _socketService.disconnect();
    return super.close();
  }
}
