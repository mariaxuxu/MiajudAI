import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/tokens/app_colors_semantic.dart';
import '../../theme/tokens/app_primitives.dart';

/// Cartao de uma entrada do diario: humor, hora, texto e categorias.
///
/// So apresenta: tudo chega pronto ([emoji], [moodLabel], [timeLabel], [text],
/// [tagLabels]). O [moodColor] colore so o rotulo do humor, que sempre vem
/// escrito, entao o significado nunca depende da cor. O emoji e ornamental e
/// fica fora da semantica.
///
/// O texto da entrada pode ser longo: ele quebra em linhas e o cartao cresce.
class DiaryEntryCard extends StatelessWidget {
  const DiaryEntryCard({
    super.key,
    required this.emoji,
    required this.moodLabel,
    required this.moodColor,
    required this.timeLabel,
    required this.text,
    this.tagLabels = const [],
  });

  final String emoji;
  final String moodLabel;
  final Color moodColor;
  final String timeLabel;
  final String text;
  final List<String> tagLabels;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.itemGap),
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppSemanticColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppPrimitives.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ExcludeSemantics(
                child: Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppSemanticColors.surfaceSubtle,
                    borderRadius: BorderRadius.circular(AppRadius.control),
                  ),
                  child: Text(
                    emoji,
                    style: const TextStyle(fontSize: 24, height: 1.2),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.itemGap),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      moodLabel,
                      style: AppTypography.titleMedium.copyWith(
                        color: moodColor,
                      ),
                    ),
                    Text(
                      timeLabel,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppSemanticColors.textSecondaryStrong,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.itemGap),
          Text(
            text,
            style: AppTypography.bodyMedium.copyWith(
              color: AppSemanticColors.textPrimary,
            ),
          ),
          if (tagLabels.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.itemGap),
            Wrap(
              spacing: AppSpacing.labelGap,
              runSpacing: AppSpacing.labelGap,
              children: [
                for (final label in tagLabels)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.itemGap,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppSemanticColors.actionPrimarySubtle,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(
                      label,
                      style: AppTypography.labelSmall.copyWith(
                        // blue700 sobre blue50: contraste AA em texto pequeno.
                        color: AppSemanticColors.actionPrimaryHover,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
