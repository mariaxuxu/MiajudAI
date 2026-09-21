import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/tokens/app_colors_semantic.dart';
import '../../widgets/chat/agent_chat_header.dart';
import '../../widgets/chat/agent_chat_scaffold.dart';
import '../../widgets/chat/agent_intro.dart';
import '../../widgets/chat/chat_error_banner.dart';
import '../../widgets/chat/chat_input_bar.dart';
import '../../widgets/chat/chat_message_bubble.dart';
import '../../widgets/chat/chat_options_menu.dart';
import '../../widgets/chat/suggestion_tile.dart';

class FinancialChatScreen extends StatefulWidget {
  const FinancialChatScreen({super.key});

  @override
  State<FinancialChatScreen> createState() => _FinancialChatScreenState();
}

/// Sugestao de pergunta. [text] e exatamente o que e enviado ao assistente;
/// [description], [icon] e [tone] so alimentam o visual do card.
class _Suggestion {
  const _Suggestion({
    required this.text,
    required this.description,
    required this.icon,
    required this.tone,
  });

  final String text;
  final String description;
  final IconData icon;
  final AppTone tone;
}

class _FinancialChatScreenState extends State<FinancialChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  static const _agent = AppAgent.luna;

  static const _suggestions = [
    _Suggestion(
      text: 'Qual meu saldo atual?',
      description: 'Veja um resumo das suas contas',
      icon: Icons.bar_chart_rounded,
      tone: AppTone.blue,
    ),
    _Suggestion(
      text: 'Como estão meus gastos este mês?',
      description: 'Analise suas despesas',
      icon: Icons.credit_card_outlined,
      tone: AppTone.blue,
    ),
    _Suggestion(
      text: 'Onde estou gastando mais?',
      description: 'Descubra seus maiores gastos',
      icon: Icons.trending_up_rounded,
      tone: AppTone.green,
    ),
    _Suggestion(
      text: 'Tenho dinheiro sobrando?',
      description: 'Veja se é um bom momento para investir',
      icon: Icons.savings_outlined,
      tone: AppTone.violet,
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _send([String? text]) {
    final message = (text ?? _controller.text).trim();
    if (message.isEmpty) return;

    final token = context.read<AuthProvider>().authToken;
    if (token == null) return;

    if (text == null) _controller.clear();
    context.read<ChatProvider>().sendMessage(message, token);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return AgentChatScaffold(
      header: _buildHeader(),
      body: _buildMessageList(),
      footer: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildErrorBanner(),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return AgentChatHeader(
      agent: _agent,
      title: 'Luna - Assistente Financeira',
      onBack: () => Navigator.pop(context),
      actions: [
        Consumer<ChatProvider>(
          builder: (_, chat, __) => chat.messages.isNotEmpty
              ? ChatOptionsMenu(onClear: () => chat.clearMessages())
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildMessageList() {
    return Consumer<ChatProvider>(
      builder: (_, chat, __) {
        if (chat.messages.isEmpty && !chat.isLoading) {
          return _buildEmptyState();
        }

        _scrollToBottom();

        return ListView.builder(
          controller: _scrollController,
          padding: EdgeInsets.symmetric(
            horizontal: AgentChatScaffold.gutterOf(context),
            vertical: AppSpacing.itemGap,
          ),
          itemCount: chat.messages.length + (chat.isLoading ? 1 : 0),
          itemBuilder: (_, i) {
            if (i == chat.messages.length) {
              return const AgentTypingBubble(agent: _agent);
            }
            final msg = chat.messages[i];
            return ChatMessageBubble(
              agent: _agent,
              text: msg.text,
              isUser: msg.isUser,
              timestamp: msg.timestamp,
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    final gutter = AgentChatScaffold.gutterOf(context);

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        gutter,
        AppSpacing.defaultGap,
        gutter,
        AppSpacing.defaultGap,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AgentIntro(
            agent: _agent,
            title: 'Assistente Financeira',
            subtitle: 'Pergunte qualquer coisa sobre suas finanças',
            note: 'Juntos por uma vida financeira mais tranquila!',
          ),
          const SizedBox(height: AppSpacing.blockGap),
          Semantics(
            header: true,
            child: Text(
              'Sugestões',
              style: AppTypography.bodyMedium.copyWith(
                color: AppSemanticColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.itemGap),
          for (final suggestion in _suggestions)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.itemGap),
              child: SuggestionTile(
                icon: suggestion.icon,
                tone: suggestion.tone,
                title: suggestion.text,
                description: suggestion.description,
                onTap: () => _send(suggestion.text),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Consumer<ChatProvider>(
      builder: (_, chat, __) {
        if (chat.error == null) return const SizedBox.shrink();
        return ChatErrorBanner(message: chat.error!);
      },
    );
  }

  Widget _buildInputBar() {
    return Consumer<ChatProvider>(
      builder: (_, chat, __) => ChatInputBar(
        controller: _controller,
        focusNode: _focusNode,
        isLoading: chat.isLoading,
        onSend: _send,
        hintText: 'Pergunte sobre suas finanças...',
      ),
    );
  }
}
