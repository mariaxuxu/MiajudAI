import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/tokens/app_colors_semantic.dart';

/// Cartao de apresentacao de um agente (Luna, Otto, Tina).
///
/// Luna, Otto e Tina compartilham a MESMA estrutura visual; so mudam avatar,
/// nome, papel, cor contextual e descricao. Por isso este componente recebe
/// um [AppAgent] em vez de cores soltas.
///
/// Acessibilidade: o papel do agente nunca e comunicado apenas por cor — ele
/// aparece sempre como texto ("Financeiro", "Cozinha", "Domestica").
///
/// Dimensionamento: o card ocupa a largura que o pai der e a ilustracao
/// acompanha via [AspectRatio], sem `LayoutBuilder`. Isso e proposital —
/// `LayoutBuilder` nao suporta dimensoes intrinsecas, e o pai usa
/// `IntrinsicHeight` para deixar os tres cards com a mesma altura.
class AgentCard extends StatelessWidget {
  const AgentCard({
    super.key,
    required this.agent,
    required this.description,
    this.showDecorativeArrow = true,
    this.maxIllustrationHeight = 76,
  });

  final AppAgent agent;
  final String description;

  /// Seta circular do prototipo. E ORNAMENTO: nao recebe toque, nao navega e
  /// nao entra na arvore de semantica. Nada nela deve sugerir interatividade.
  final bool showDecorativeArrow;

  final double maxIllustrationHeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: agent.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxIllustrationHeight),
            child: AspectRatio(
              aspectRatio: 1.05,
              child: Image.asset(
                agent.assetPath,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.medium,
                excludeFromSemantics: true,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            agent.name,
            textAlign: TextAlign.center,
            style: AppTypography.titleMedium.copyWith(
              color: AppSemanticColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            agent.role,
            textAlign: TextAlign.center,
            style: AppTypography.labelSmall.copyWith(
              color: agent.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            textAlign: TextAlign.center,
            style: AppTypography.bodySmall.copyWith(
              fontSize: 12,
              color: AppSemanticColors.textSecondaryStrong,
            ),
          ),
          if (showDecorativeArrow) ...[
            const SizedBox(height: 12),
            _DecorativeArrow(agent: agent),
          ],
        ],
      ),
    );
  }
}

/// Ornamento. Sem [GestureDetector], sem [InkWell], sem [Semantics].
class _DecorativeArrow extends StatelessWidget {
  const _DecorativeArrow({required this.agent});

  final AppAgent agent;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: agent.accent.withValues(alpha: 0.14),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.arrow_forward_rounded,
          size: 18,
          color: agent.onSurface,
        ),
      ),
    );
  }
}
