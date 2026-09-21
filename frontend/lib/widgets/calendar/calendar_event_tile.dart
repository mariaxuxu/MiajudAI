import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/tokens/app_colors_semantic.dart';
import '../../theme/tokens/app_primitives.dart';

/// Item da lista de compromissos de um dia: icone tonal, titulo, data e acoes.
///
/// So apresenta: [title] e [dateLabel] chegam prontos e as [actions] (remover)
/// sao widgets de quem usa, com o proprio tooltip e destino. O texto quebra em
/// vez de estourar quando o espaco aperta (tela estreita ou texto ampliado).
class CalendarEventTile extends StatelessWidget {
  const CalendarEventTile({
    super.key,
    required this.title,
    required this.dateLabel,
    this.actions = const [],
  });

  final String title;
  final String dateLabel;

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
        children: [
          ExcludeSemantics(
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTone.blue.surface,
                borderRadius: BorderRadius.circular(AppRadius.control),
              ),
              child: Icon(
                Icons.event_rounded,
                size: AppSizes.iconLg,
                color: AppTone.blue.foreground,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.itemGap),
          Expanded(
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
                  dateLabel,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppSemanticColors.textSecondaryStrong,
                  ),
                ),
              ],
            ),
          ),
          ...actions,
        ],
      ),
    );
  }
}
