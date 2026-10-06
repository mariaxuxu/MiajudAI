import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../services/chat_service.dart';

class ChatProvider extends ChangeNotifier {
  final ChatService _chatService = ChatService();
  final String agentKey;
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String? _error;

  ChatProvider({this.agentKey = 'luna'});

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> sendMessage(String text, String token) async {
    _error = null;
    _messages.add(ChatMessage(text: text, isUser: true, timestamp: DateTime.now()));
    _isLoading = true;
    notifyListeners();

    try {
      final historyToSend = _messages.length > 21
          ? _messages.sublist(_messages.length - 21, _messages.length - 1)
          : _messages.sublist(0, _messages.length - 1);

      final result = await _chatService.sendMessage(agentKey, text, historyToSend, token);

      if (result.routed) {
        _messages.add(ChatMessage(
          text: result.routeMessage!,
          isUser: false,
          timestamp: DateTime.now(),
          isRouted: true,
          routeTarget: result.routeTarget,
        ));
      } else {
        _messages.add(ChatMessage(
          text: result.reply!,
          isUser: false,
          timestamp: DateTime.now(),
        ));
      }
    } catch (_) {
      _messages.removeLast();
      _error = 'Não foi possível conectar ao assistente. Tente novamente.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearMessages() {
    _messages.clear();
    _error = null;
    notifyListeners();
  }
}
