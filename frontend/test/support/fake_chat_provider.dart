import 'package:flutter/foundation.dart';
import 'package:miajudai/models/chat_message.dart';
import 'package:miajudai/providers/chat_provider.dart';

/// `ChatProvider` de teste.
///
/// O real conversa com o backend. Este fake nao faz rede: expoe o estado que a
/// tela consome (mensagens, carregando, erro) e REGISTRA as chamadas, para os
/// testes provarem que a UI continua acionando o provider do mesmo jeito.
class FakeChatProvider extends ChangeNotifier implements ChatProvider {
  List<ChatMessage> items = [];
  bool loading = false;
  String? errorMessage;

  /// Cada chamada a `sendMessage`, na ordem.
  final List<({String text, String token})> sent = [];

  /// Quantas vezes `clearMessages()` foi chamado.
  int clearCalls = 0;

  /// Troca o estado e avisa os ouvintes (a tela reconstroi como no real).
  void update({
    List<ChatMessage>? items,
    bool? loading,
    String? errorMessage,
  }) {
    if (items != null) this.items = items;
    if (loading != null) this.loading = loading;
    this.errorMessage = errorMessage;
    notifyListeners();
  }

  @override
  List<ChatMessage> get messages => List.unmodifiable(items);

  @override
  bool get isLoading => loading;

  @override
  String? get error => errorMessage;

  @override
  Future<void> sendMessage(String text, String token) async {
    sent.add((text: text, token: token));
  }

  @override
  void clearMessages() {
    clearCalls++;
    items = [];
    errorMessage = null;
    notifyListeners();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
