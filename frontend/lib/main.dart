import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/chat_bloc.dart';
import 'screens/join_screen.dart';
import 'services/socket_service.dart';

void main() {
  runApp(const ChatApp());
}

class ChatApp extends StatelessWidget {
  const ChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    final socketService = SocketService(
      serverUrl: 'http://localhost:3000',
    );

    return BlocProvider(
      create: (context) => ChatBloc(socketService),
      child: MaterialApp(
        title: 'Group Chat',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.black,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        home: const JoinScreen(),
      ),
    );
  }
}
