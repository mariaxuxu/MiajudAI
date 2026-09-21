import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/tokens/app_colors_semantic.dart';
import 'finance_tone.dart';

/// Card de resumo tonal: icone, rotulo, valor grande e legenda.
///
/// E o irmao claro do `BalanceHeroCard` (navy): o mesmo desenho, mas com a cor
/// do dominio ([tone]) em vez do azul de marca. Serve ao total do mes de
/// Receitas e, adiante, ao de Despesas.
///
/// Lido como um unico bloco ("rotulo, valor, legenda"); as curvas e o glifo de
/// barras sao ornamentais. O valor encolhe para caber em vez de estourar.
///
/// Nao formata nada: [value] e [caption] chegam prontos de quem usa.
class TonalSummaryCard extends StatelessWidget {
  const TonalSummaryCard({
    super.key,
    required this.tone,
    required this.icon,
    required this.label,
    required this.value,
    required this.caption,
  });

  final FinanceTone tone;
  final IconData icon;
  final String label;
  final String value;
  final String caption;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadius.card);

    return Semantics(
      container: true,
      label: '$label, $value, $caption',
      child: ExcludeSemantics(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: tone.background,
            borderRadius: radius,
            border: Border.all(color: tone.border),
          ),
          child: ClipRRect(
            borderRadius: radius,
            child: Stack(
              children: [
                Positioned(right: -36, top: -48, child: _Disc(tone, 150)),
                Positioned(right: -8, bottom: -56, child: _Disc(tone, 100)),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.cardPadding),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: tone.tone.surface,
                          borderRadius:
                              BorderRadius.circular(AppRadius.control),
                        ),
                        child: Icon(
                          icon,
                          size: AppSizes.iconLg,
                          color: tone.tone.foreground,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.itemGap),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              label,
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppSemanticColors.textSecondaryStrong,
                              ),
                            ),
                            const SizedBox(height: 2),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                value,
                                style: AppTypography.displayMedium.copyWith(
                                  color: tone.value,
                                ),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              caption,
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppSemanticColors.textSecondaryStrong,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.labelGap),
                      Icon(
                        Icons.bar_chart_rounded,
                        size: 36,
                        color: tone.tone.foreground,
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
  const _Disc(this.tone, this.diameter);

  final FinanceTone tone;
  final double diameter;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: tone.tone.foreground.withValues(alpha: 0.07),
      ),
    );
  }
}
