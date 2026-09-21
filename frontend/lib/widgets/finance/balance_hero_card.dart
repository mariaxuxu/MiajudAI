import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/tokens/app_colors_semantic.dart';
import '../../theme/tokens/app_primitives.dart';

/// Card de destaque navy com um valor grande: rotulo, valor e legenda.
///
/// O card e lido como um unico bloco ("rotulo, valor, legenda") e as curvas
/// decorativas saem da semantica. O valor encolhe para caber (`FittedBox`) em
/// telas estreitas ou com texto ampliado, em vez de estourar a largura.
///
/// Nao formata nada: [value] e [caption] chegam prontos de quem usa.
class BalanceHeroCard extends StatelessWidget {
  const BalanceHeroCard({
    super.key,
    required this.label,
    required this.value,
    required this.caption,
  });

  final String label;
  final String value;
  final String caption;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadius.hero);

    return Semantics(
      container: true,
      label: '$label, $value, $caption',
      child: ExcludeSemantics(
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: radius,
            boxShadow: AppPrimitives.shadowMd,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppSemanticColors.surfaceStrong,
                AppSemanticColors.surfaceStrongDeep,
              ],
            ),
          ),
          child: ClipRRect(
            borderRadius: radius,
            child: Stack(
              children: [
                const Positioned(right: -56, top: -24, child: _Disc(200)),
                const Positioned(right: -12, bottom: -92, child: _Disc(180)),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.blockGap),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: AppTypography.titleSmall.copyWith(
                          color: AppSemanticColors.onSurfaceStrongMuted,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.itemGap),
                      SizedBox(
                        width: double.infinity,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            value,
                            style: AppTypography.displayMedium.copyWith(
                              color: AppSemanticColors.onSurfaceStrong,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.labelGap),
                      Text(
                        caption,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppSemanticColors.onSurfaceStrongMuted,
                        ),
                      ),
                    ],
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

/// Disco translucido usado como curva de fundo do card.
class _Disc extends StatelessWidget {
  const _Disc(this.diameter);

  final double diameter;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppSemanticColors.onSurfaceStrong.withValues(alpha: 0.05),
      ),
    );
  }
}
