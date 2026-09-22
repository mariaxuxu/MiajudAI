import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/tokens/app_colors_semantic.dart';
import '../../theme/tokens/app_primitives.dart';

/// Sugestao de pergunta: icone em bloco tonal, pergunta, descricao e seta.
///
/// Toda a superficie e o alvo de toque (InkWell) e ganha foco, ripple e
/// semantica de botao. O significado nunca depende so da cor: a pergunta e a
/// descricao dizem o que a sugestao faz. Quem usa decide o que o toque envia.
class SuggestionTile extends StatelessWidget {
  const SuggestionTile({
    super.key,
    required this.icon,
    required this.tone,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final IconData icon;
  final AppTone tone;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadius.card);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppSemanticColors.surface,
        borderRadius: radius,
        boxShadow: AppPrimitives.shadowSm,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.cardPadding,
              vertical: AppSpacing.itemGap,
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: tone.surface,
                    borderRadius: BorderRadius.circular(AppRadius.control),
                  ),
                  child: Icon(
                    icon,
                    size: AppSizes.iconLg,
                    color: tone.foreground,
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
                        description,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppSemanticColors.textSecondaryStrong,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.labelGap),
                const ExcludeSemantics(
                  child: Icon(
                    Icons.chevron_right_rounded,
                    size: AppSizes.iconLg,
                    color: AppSemanticColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
