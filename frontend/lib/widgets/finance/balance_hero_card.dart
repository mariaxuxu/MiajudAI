import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/tokens/app_colors_semantic.dart';
import '../../theme/tokens/app_primitives.dart';

/// Card de destaque navy com um valor grande: rotulo, valor e legenda.
///
/// Sem [control], o card e lido como um unico bloco ("rotulo, valor, legenda")
/// e as curvas decorativas saem da semantica. O valor encolhe para caber
/// (`FittedBox`) em telas estreitas ou com texto ampliado, em vez de estourar a
/// largura.
///
/// [control] e uma faixa interativa entre o rotulo e o valor (ex.: navegacao de
/// mes). Como um controle nao pode ser engolido por um bloco de leitura unico,
/// com ele o card e lido em duas partes ("rotulo" e "valor, legenda") e o
/// controle fica acessivel entre elas. [icon] e um glifo decorativo antes do
/// rotulo.
///
/// Nao formata nada: [value] e [caption] chegam prontos de quem usa.
class BalanceHeroCard extends StatelessWidget {
  const BalanceHeroCard({
    super.key,
    required this.label,
    required this.value,
    required this.caption,
    this.icon,
    this.control,
  });

  final String label;
  final String value;
  final String caption;

  /// Glifo decorativo antes do rotulo.
  final IconData? icon;

  /// Faixa interativa entre o rotulo e o valor.
  final Widget? control;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadius.hero);
    final icon = this.icon;
    final control = this.control;

    final labelText = Text(
      label,
      style: AppTypography.titleSmall.copyWith(
        color: AppSemanticColors.onSurfaceStrongMuted,
      ),
    );
    final labelRow = icon == null
        ? labelText
        : Row(
            children: [
              Icon(
                icon,
                size: AppSizes.iconMd,
                color: AppSemanticColors.onSurfaceStrongMuted,
              ),
              const SizedBox(width: AppSpacing.labelGap),
              Flexible(child: labelText),
            ],
          );
    final valueText = SizedBox(
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
    );
    final captionText = Text(
      caption,
      style: AppTypography.bodyMedium.copyWith(
        color: AppSemanticColors.onSurfaceStrongMuted,
      ),
    );

    final card = DecoratedBox(
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
                children: control == null
                    ? [
                        labelRow,
                        const SizedBox(height: AppSpacing.itemGap),
                        valueText,
                        const SizedBox(height: AppSpacing.labelGap),
                        captionText,
                      ]
                    : [
                        _Reading(label: label, child: labelRow),
                        const SizedBox(height: AppSpacing.itemGap),
                        SizedBox(width: double.infinity, child: control),
                        const SizedBox(height: AppSpacing.itemGap),
                        _Reading(
                          label: '$value, $caption',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              valueText,
                              const SizedBox(height: AppSpacing.labelGap),
                              captionText,
                            ],
                          ),
                        ),
                      ],
              ),
            ),
          ],
        ),
      ),
    );

    if (control != null) return card;

    return Semantics(
      container: true,
      label: '$label, $value, $caption',
      child: ExcludeSemantics(child: card),
    );
  }
}

/// Um trecho do card lido como um unico bloco de texto.
class _Reading extends StatelessWidget {
  const _Reading({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: label,
      child: ExcludeSemantics(child: child),
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
