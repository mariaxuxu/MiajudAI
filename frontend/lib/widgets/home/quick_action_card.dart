import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/tokens/app_colors_semantic.dart';
import '../../theme/tokens/app_primitives.dart';

/// Atalho da home: icone em bloco tonal, titulo, descricao e seta.
///
/// Toda a superficie e o alvo de toque (InkWell), entao ganha foco, ripple e
/// semantica de botao. O significado nunca depende so da cor: o titulo e a
/// descricao dizem para onde o atalho leva.
///
/// Este widget nao decide o destino — quem o usa passa [onTap].
class QuickActionCard extends StatelessWidget {
  const QuickActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.tone,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final AppTone tone;
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
            padding: const EdgeInsets.all(AppSpacing.cardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: tone.surface,
                        borderRadius: BorderRadius.circular(AppRadius.control),
                      ),
                      child: Icon(icon,
                          size: AppSizes.iconLg, color: tone.foreground),
                    ),
                    const Spacer(),
                    const ExcludeSemantics(
                      child: Icon(
                        Icons.chevron_right_rounded,
                        size: AppSizes.iconLg,
                        color: AppSemanticColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.itemGap),
                Text(
                  title,
                  style: AppTypography.titleMedium.copyWith(
                    color: AppSemanticColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppSemanticColors.textSecondaryStrong,
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
