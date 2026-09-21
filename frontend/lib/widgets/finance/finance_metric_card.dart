import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/tokens/app_colors_semantic.dart';
import 'finance_tone.dart';

/// Card de metrica em coluna: bloco de icone no topo, rotulo, valor e legenda.
///
/// Feito para ficar em pares, lado a lado (ex.: Parcelas e Fixos). Nao e o
/// `TonalSummaryCard`, que e uma linha larga de um unico total do mes: aqui o
/// conteudo empilha para caber em meia largura.
///
/// Lido como um unico bloco ("rotulo, valor, legenda"); o disco de fundo e
/// ornamental. O valor encolhe para caber em vez de estourar a meia largura.
/// Nao e tocavel: so informa.
///
/// Nao formata nada: [value] e [caption] chegam prontos de quem usa.
class FinanceMetricCard extends StatelessWidget {
  const FinanceMetricCard({
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

  static const TextStyle _valueStyle = AppTypography.headlineLarge;

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
                Positioned(
                  right: -32,
                  top: -40,
                  child: Container(
                    width: 112,
                    height: 112,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: tone.tone.foreground.withValues(alpha: 0.07),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.cardPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
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
                      const SizedBox(height: AppSpacing.itemGap),
                      Text(
                        label,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppSemanticColors.textSecondaryStrong,
                        ),
                      ),
                      const SizedBox(height: 2),
                      // Altura fixa (uma linha do estilo, ja com o texto
                      // ampliado): dois cards lado a lado nao ficam com alturas
                      // diferentes so porque um dos valores encolheu.
                      SizedBox(
                        width: double.infinity,
                        height: MediaQuery.textScalerOf(context).scale(
                          _valueStyle.fontSize! * _valueStyle.height!,
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            value,
                            style: _valueStyle.copyWith(
                              color: AppSemanticColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        caption,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppSemanticColors.textSecondaryStrong,
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
