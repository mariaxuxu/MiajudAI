import 'api_service.dart';
import '../models/chat_message.dart';

class ChatService {
  final ApiService _api = ApiService();

  Future<String> sendMessage(
    String message,
    List<ChatMessage> history,
    String token,
  ) async {
    final response = await _api.post(
      '/chat/financial',
      {
        'message': message,
        'history': history.map((m) => m.toJson()).toList(),
      },
      token: token,
    );
    return response['reply'] as String;
  }
}
