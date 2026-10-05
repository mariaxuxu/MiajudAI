import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/tokens/app_colors_semantic.dart';
import '../../models/chat_message.dart';
import '../../widgets/chat/agent_chat_header.dart';
import '../../widgets/chat/agent_chat_scaffold.dart';
import '../../widgets/chat/agent_intro.dart';
import '../../widgets/chat/chat_error_banner.dart';
import '../../widgets/chat/chat_input_bar.dart';
import '../../widgets/chat/chat_message_bubble.dart';
import '../../widgets/chat/chat_options_menu.dart';
import '../../widgets/chat/suggestion_tile.dart';

class AgentChatScreen extends StatelessWidget {
  final AppAgent agent;

  const AgentChatScreen({super.key, required this.agent});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChatProvider(agentKey: agent.name.toLowerCase()),
      child: _AgentChatBody(agent: agent),
    );
  }
}

class _AgentSuggestion {
  const _AgentSuggestion({
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

const _lunaS = [
  _AgentSuggestion(text: 'Qual meu saldo atual?', description: 'Veja um resumo das suas contas', icon: Icons.bar_chart_rounded, tone: AppTone.blue),
  _AgentSuggestion(text: 'Como estão meus gastos este mês?', description: 'Analise suas despesas', icon: Icons.credit_card_outlined, tone: AppTone.blue),
  _AgentSuggestion(text: 'Onde estou gastando mais?', description: 'Descubra seus maiores gastos', icon: Icons.trending_up_rounded, tone: AppTone.green),
  _AgentSuggestion(text: 'Tenho dinheiro sobrando?', description: 'Veja se é um bom momento para investir', icon: Icons.savings_outlined, tone: AppTone.violet),
];

const _ottoS = [
  _AgentSuggestion(text: 'O que posso cozinhar hoje?', description: 'Receitas rápidas com o que você tem', icon: Icons.restaurant_outlined, tone: AppTone.amber),
  _AgentSuggestion(text: 'Me ajuda a montar uma lista de compras', description: 'Planeje seu supermercado da semana', icon: Icons.shopping_cart_outlined, tone: AppTone.amber),
  _AgentSuggestion(text: 'Quero comer saudável gastando pouco', description: 'Dicas de alimentação econômica', icon: Icons.eco_outlined, tone: AppTone.green),
  _AgentSuggestion(text: 'Receita fácil para iniciantes', description: 'Pratos simples para quem está aprendendo', icon: Icons.soup_kitchen_outlined, tone: AppTone.amber),
];

const _tinaS = [
  _AgentSuggestion(text: 'Como organizo meu apartamento pequeno?', description: 'Dicas de otimização de espaço', icon: Icons.home_outlined, tone: AppTone.green),
  _AgentSuggestion(text: 'Me ajuda a criar uma rotina de limpeza', description: 'Organize as tarefas da semana', icon: Icons.cleaning_services_outlined, tone: AppTone.green),
  _AgentSuggestion(text: 'Como limpar o banheiro de forma rápida?', description: 'Truques de limpeza eficiente', icon: Icons.bathroom_outlined, tone: AppTone.cyan),
  _AgentSuggestion(text: 'Dicas para manter a casa arrumada', description: 'Hábitos para um lar organizado', icon: Icons.auto_fix_high_outlined, tone: AppTone.violet),
];

List<_AgentSuggestion> _suggestionsFor(AppAgent agent) {
  switch (agent) {
    case AppAgent.otto:
      return _ottoS;
    case AppAgent.tina:
      return _tinaS;
    case AppAgent.luna:
      return _lunaS;
  }
}

class _AgentChatBody extends StatefulWidget {
  final AppAgent agent;
  const _AgentChatBody({required this.agent});

  @override
  State<_AgentChatBody> createState() => _AgentChatBodyState();
}

class _AgentChatBodyState extends State<_AgentChatBody> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

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

  void _navigateToAgent(String agentKey) {
    Navigator.pushReplacementNamed(context, '/chat/$agentKey');
  }

  @override
  Widget build(BuildContext context) {
    return AgentChatScaffold(
      header: _buildHeader(),
      body: _buildMessageList(),
      footer: Column(
        mainAxisSize: MainAxisSize.min,
        children: [_buildErrorBanner(), _buildInputBar()],
      ),
    );
  }

  Widget _buildHeader() {
    return AgentChatHeader(
      agent: widget.agent,
      title: '${widget.agent.name} — ${widget.agent.role}',
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
        if (chat.messages.isEmpty && !chat.isLoading) return _buildEmptyState();
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
              return AgentTypingBubble(agent: widget.agent);
            }
            final msg = chat.messages[i];
            if (!msg.isUser && msg.isRouted && msg.routeTarget != null) {
              return _buildRoutedItem(msg);
            }
            return ChatMessageBubble(
              agent: widget.agent,
              text: msg.text,
              isUser: msg.isUser,
              timestamp: msg.timestamp,
            );
          },
        );
      },
    );
  }

  Widget _buildRoutedItem(ChatMessage msg) {
    final targetAgent = AppAgent.values.firstWhere(
      (a) => a.name.toLowerCase() == msg.routeTarget,
      orElse: () => AppAgent.luna,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ChatMessageBubble(
          agent: widget.agent,
          text: msg.text,
          isUser: false,
          timestamp: msg.timestamp,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 44, bottom: AppSpacing.itemGap),
          child: TextButton.icon(
            onPressed: () => _navigateToAgent(msg.routeTarget!),
            icon: const Icon(Icons.open_in_new_rounded, size: 16),
            label: Text('Falar com ${targetAgent.name}'),
            style: TextButton.styleFrom(foregroundColor: targetAgent.accent),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    final gutter = AgentChatScaffold.gutterOf(context);
    final suggestions = _suggestionsFor(widget.agent);
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(gutter, AppSpacing.defaultGap, gutter, AppSpacing.defaultGap),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AgentIntro(
            agent: widget.agent,
            title: widget.agent.role,
            subtitle: 'Pergunte qualquer coisa sobre ${widget.agent.role.toLowerCase()}',
            note: 'Aqui para ajudar com ${widget.agent.role.toLowerCase()}!',
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
          for (final s in suggestions)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.itemGap),
              child: SuggestionTile(
                icon: s.icon,
                tone: s.tone,
                title: s.text,
                description: s.description,
                onTap: () => _send(s.text),
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
        hintText: 'Pergunte sobre ${widget.agent.role.toLowerCase()}...',
      ),
    );
  }
}
