import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/tokens/app_colors_semantic.dart';
import '../../theme/tokens/app_primitives.dart';
import 'finance_tone.dart';

/// Item de lista de um registro financeiro: icone tonal, titulo, meta, valor
/// e acoes.
///
/// So apresenta: [title], [subtitle] e [amount] chegam prontos e as [actions]
/// (editar, remover...) sao widgets de quem usa, com seus proprios
/// tooltips e destinos. Nada aqui decide o que uma acao faz.
///
/// As acoes ficam a direita, cada uma com alvo de toque de 48dp. O texto
/// quebra em vez de estourar quando o espaco aperta (tela estreita ou texto
/// ampliado).
class FinanceRecordTile extends StatelessWidget {
  const FinanceRecordTile({
    super.key,
    required this.tone,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.amount,
    this.actions = const [],
  });

  final FinanceTone tone;
  final IconData icon;
  final String title;
  final String subtitle;
  final String amount;

  /// Acoes a direita do item (icones de 48dp).
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.itemGap),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.cardPadding,
        AppSpacing.itemGap,
        AppSpacing.labelGap,
        AppSpacing.itemGap,
      ),
      decoration: BoxDecoration(
        color: AppSemanticColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppPrimitives.shadowSm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExcludeSemantics(
            child: Container(
              width: 44,
              height: 44,
              margin: const EdgeInsets.only(top: AppSpacing.labelGap / 2),
              decoration: BoxDecoration(
                color: tone.tone.surface,
                borderRadius: BorderRadius.circular(AppRadius.control),
              ),
              child: Icon(
                icon,
                size: AppSizes.iconLg,
                color: tone.tone.foreground,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.itemGap),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.titleMedium.copyWith(
                      color: AppSemanticColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppSemanticColors.textSecondaryStrong,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.labelGap),
                  Text(
                    amount,
                    style: AppTypography.headlineSmall.copyWith(
                      color: tone.value,
                    ),
                  ),
                ],
              ),
            ),
          ),
          ...actions,
        ],
      ),
    );
  }
}
