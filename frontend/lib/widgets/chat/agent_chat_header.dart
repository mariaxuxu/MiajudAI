import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/tokens/app_colors_semantic.dart';
import '../agents/agent_avatar.dart';

/// Cabecalho do chat de um agente: voltar, avatar, titulo e acoes.
///
/// Os alvos de toque tem 48dp. O botao de voltar so dispara [onBack]; quem
/// usa decide o que "voltar" significa.
class AgentChatHeader extends StatelessWidget {
  const AgentChatHeader({
    super.key,
    required this.agent,
    required this.title,
    required this.onBack,
    this.actions = const [],
  });

  final AppAgent agent;
  final String title;
  final VoidCallback onBack;

  /// Acoes a direita (ex.: menu de opcoes).
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.labelGap,
        AppSpacing.labelGap,
        AppSpacing.labelGap,
        AppSpacing.labelGap,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            tooltip: 'Voltar',
            icon: const Icon(Icons.arrow_back_rounded),
            color: AppSemanticColors.textPrimary,
          ),
          const SizedBox(width: 4),
          AgentAvatar(agent: agent),
          const SizedBox(width: AppSpacing.itemGap),
          Expanded(
            child: Semantics(
              header: true,
              child: Text(
                title,
                style: AppTypography.titleMedium.copyWith(
                  color: AppSemanticColors.textPrimary,
                ),
              ),
            ),
          ),
          ...actions,
        ],
      ),
    );
  }
}
