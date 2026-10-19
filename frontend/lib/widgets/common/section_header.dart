import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/tokens/app_colors_semantic.dart';

/// Titulo de secao: barra vertical colorida, titulo e contador opcional.
///
/// A cor da barra ([accent]) identifica o dominio (azul, verde, vermelho,
/// ambar), mas o significado nunca depende dela: o titulo diz do que se trata.
/// O contador e sempre neutro para funcionar sobre qualquer cor de dominio.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.count = 0,
    this.accent = AppSemanticColors.actionPrimary,
  });

  final String title;

  /// Quantidade de itens da secao. Nao aparece quando e zero.
  final int count;

  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      header: true,
      label: count > 0 ? '$title, $count' : title,
      child: ExcludeSemantics(
        child: Row(
          children: [
            Container(
              width: 4,
              height: 22,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
            ),
            const SizedBox(width: AppSpacing.itemGap),
            Flexible(
              child: Text(
                title,
                style: AppTypography.headlineSmall.copyWith(
                  color: AppSemanticColors.textPrimary,
                ),
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: AppSpacing.labelGap),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.labelGap,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppSemanticColors.surfaceSubtle,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  '$count',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppSemanticColors.textSecondaryStrong,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
