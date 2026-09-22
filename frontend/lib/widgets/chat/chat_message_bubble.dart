import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/tokens/app_colors_semantic.dart';
import '../agents/agent_avatar.dart';

/// Formato das laterais de uma bolha: o canto junto ao autor e quase reto.
BorderRadius _bubbleRadius({required bool isUser}) => BorderRadius.only(
      topLeft: const Radius.circular(AppRadius.card),
      topRight: const Radius.circular(AppRadius.card),
      bottomLeft: Radius.circular(isUser ? AppRadius.card : 4),
      bottomRight: Radius.circular(isUser ? 4 : AppRadius.card),
    );

/// Bolha de mensagem do chat: do usuario (azul, a direita) ou do agente
/// (branca, a esquerda, com avatar).
///
/// A autoria nunca depende so de cor e posicao: leitores de tela anunciam
/// "Voce" ou o nome do agente antes do texto.
class ChatMessageBubble extends StatelessWidget {
  const ChatMessageBubble({
    super.key,
    required this.agent,
    required this.text,
    required this.isUser,
    required this.timestamp,
  });

  final AppAgent agent;
  final String text;
  final bool isUser;
  final DateTime timestamp;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.itemGap),
      child: Semantics(
        container: true,
        label: isUser ? 'Você' : agent.name,
        child: Row(
          mainAxisAlignment:
              isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isUser) ...[
              AgentAvatar(agent: agent, size: 32),
              const SizedBox(width: AppSpacing.labelGap),
            ],
            Flexible(
              child: LayoutBuilder(
                builder: (context, constraints) => ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: constraints.maxWidth * 0.86,
                  ),
                  child: _buildBubble(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBubble() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.cardPadding,
        vertical: AppSpacing.itemGap,
      ),
      decoration: BoxDecoration(
        color: isUser
            ? AppSemanticColors.actionPrimary
            : AppSemanticColors.surface,
        borderRadius: _bubbleRadius(isUser: isUser),
        border: isUser ? null : Border.all(color: AppSemanticColors.border),
      ),
      // A bolha se ajusta ao texto (ate o maximo): o horario alinha a direita
      // da largura do proprio conteudo, nao da linha inteira.
      child: IntrinsicWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              text,
              style: AppTypography.bodyMedium.copyWith(
                color: isUser
                    ? AppSemanticColors.onAction
                    : AppSemanticColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                DateFormat('HH:mm').format(timestamp),
                style: AppTypography.labelSmall.copyWith(
                  // Sobre o azul de acao, o azul 50 mantem contraste AA.
                  color: isUser
                      ? AppSemanticColors.actionPrimarySubtle
                      : AppSemanticColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bolha "digitando..." do agente enquanto a resposta nao chega.
class AgentTypingBubble extends StatelessWidget {
  const AgentTypingBubble({super.key, required this.agent});

  final AppAgent agent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.itemGap),
      child: Semantics(
        container: true,
        liveRegion: true,
        label: '${agent.name} está digitando',
        child: ExcludeSemantics(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AgentAvatar(agent: agent, size: 32),
              const SizedBox(width: AppSpacing.labelGap),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.cardPadding,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: AppSemanticColors.surface,
                  borderRadius: _bubbleRadius(isUser: false),
                  border: Border.all(color: AppSemanticColors.border),
                ),
                child: const _TypingDots(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypingDots extends StatefulWidget {
  const _TypingDots();

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) {
          final delay = i * 0.28;
          final p = ((_ctrl.value - delay) % 1.0 + 1.0) % 1.0;
          final opacity = (p < 0.5 ? p * 2 : (1.0 - p) * 2).clamp(0.25, 1.0);
          return Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: AppSemanticColors.textSecondary.withValues(alpha: opacity),
              shape: BoxShape.circle,
            ),
          );
        }),
      ),
    );
  }
}
