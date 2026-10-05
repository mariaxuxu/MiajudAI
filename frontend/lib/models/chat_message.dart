class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isRouted;
  final String? routeTarget;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isRouted = false,
    this.routeTarget,
  });

  Map<String, dynamic> toJson() => {
        'text': text,
        'isUser': isUser,
      };
}
