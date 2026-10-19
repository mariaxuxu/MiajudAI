import 'api_service.dart';
import '../models/chat_message.dart';

class ChatServiceResult {
  final bool routed;
  final String? reply;
  final String? routeTarget;
  final String? routeMessage;

  const ChatServiceResult.reply(String r)
      : routed = false,
        reply = r,
        routeTarget = null,
        routeMessage = null;

  const ChatServiceResult.route({required String target, required String message})
      : routed = true,
        reply = null,
        routeTarget = target,
        routeMessage = message;
}

class ChatService {
  final ApiService _api = ApiService();

  Future<ChatServiceResult> sendMessage(
    String agentKey,
    String message,
    List<ChatMessage> history,
    String token,
  ) async {
    final response = await _api.post(
      '/chat/message',
      {
        'agent': agentKey,
        'message': message,
        'history': history.map((m) => m.toJson()).toList(),
      },
      token: token,
    );

    if (response['routed'] == true) {
      return ChatServiceResult.route(
        target: response['target'] as String,
        message: response['message'] as String,
      );
    }
    return ChatServiceResult.reply(response['reply'] as String);
  }
}
