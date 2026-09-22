import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/tokens/app_colors_semantic.dart';
import 'finance_tone.dart';

/// Card de dica: lampada em bloco tonal, titulo e texto.
///
/// Conteudo estatico e puramente informativo: nao e tocavel e nao leva a lugar
/// nenhum. Lido como um unico bloco.
class TipCard extends StatelessWidget {
  const TipCard({
    super.key,
    required this.tone,
    required this.title,
    required this.message,
  });

  final FinanceTone tone;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(
          color: tone.background,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: tone.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExcludeSemantics(
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: tone.tone.surface,
                  borderRadius: BorderRadius.circular(AppRadius.control),
                ),
                child: Icon(
                  Icons.lightbulb_outline_rounded,
                  size: AppSizes.iconLg,
                  color: tone.tone.foreground,
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
                  const SizedBox(height: 2),
                  Text(
                    message,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppSemanticColors.textSecondaryStrong,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
