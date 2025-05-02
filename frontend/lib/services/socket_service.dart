import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:async';

class SocketService {
  late WebSocketChannel channel;
  final String serverUrl;
  void Function(Map<String, dynamic>)? onNewMessage;
  void Function(Map<String, dynamic>)? onUserJoined;
  void Function(Map<String, dynamic>)? onUserLeft;
  void Function(Map<String, dynamic>)? onUserTyping;

  SocketService({
    required this.serverUrl,
    this.onNewMessage,
    this.onUserJoined,
    this.onUserLeft,
    this.onUserTyping,
  });

  void connect() {
    final wsUrl = serverUrl.replaceFirst('http', 'ws') + '/ws';
    channel = WebSocketChannel.connect(Uri.parse(wsUrl));

    channel.stream.listen(
      (message) {
        final data = jsonDecode(message);
        final type = data['type'] as String;
        final eventData = data['data'] as Map<String, dynamic>;

        switch (type) {
          case 'new_message':
            onNewMessage?.call(eventData);
            break;
          case 'user_joined':
            onUserJoined?.call(eventData);
            break;
          case 'user_left':
            onUserLeft?.call(eventData);
            break;
          case 'user_typing':
            onUserTyping?.call(eventData);
            break;
          case 'previous_messages':
            final messages =
                (data['messages'] as List).cast<Map<String, dynamic>>();
            for (final message in messages) {
              onNewMessage?.call(message);
            }
            break;
        }
      },
      onError: (error) => print('WebSocket Error: $error'),
      onDone: () => print('WebSocket connection closed'),
    );
  }

  void joinChat(String username) {
    _sendEvent('join', {'username': username});
  }

  void sendMessage(String message) {
    _sendEvent('message', {'message': message});
  }

  void sendTypingStatus(bool isTyping) {
    _sendEvent('typing', {'isTyping': isTyping});
  }

  void _sendEvent(String type, Map<String, dynamic> data) {
    final event = {
      'type': type,
      ...data,
    };
    channel.sink.add(jsonEncode(event));
  }

  void disconnect() {
    channel.sink.close();
  }
}
