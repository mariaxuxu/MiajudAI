import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../services/chat_service.dart';

class ChatProvider extends ChangeNotifier {
  final ChatService _chatService = ChatService();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String? _error;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> sendMessage(String text, String token) async {
    _error = null;
    _messages.add(ChatMessage(text: text, isUser: true, timestamp: DateTime.now()));
    _isLoading = true;
    notifyListeners();

    try {
      // Send up to 20 previous messages as context (excluding the one just added)
      final historyToSend = _messages.length > 21
          ? _messages.sublist(_messages.length - 21, _messages.length - 1)
          : _messages.sublist(0, _messages.length - 1);

      final reply = await _chatService.sendMessage(text, historyToSend, token);
      _messages.add(ChatMessage(text: reply, isUser: false, timestamp: DateTime.now()));
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
