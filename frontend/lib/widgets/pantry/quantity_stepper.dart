import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/tokens/app_colors_semantic.dart';

/// Stepper −/+ com o valor no meio, ambos os botoes com alvo de 48dp.
///
/// So apresenta: o [value], o piso ([minValue]) e o que cada toque faz
/// chegam de fora. [onDecrement] nulo desabilita o "−" (ex.: no piso).
class QuantityStepper extends StatelessWidget {
  const QuantityStepper({
    super.key,
    required this.value,
    required this.onIncrement,
    required this.onDecrement,
    this.minValue = 0,
    this.semanticsLabel,
  });

  final int value;
  final VoidCallback onIncrement;

  /// Nulo desabilita o botao "−".
  final VoidCallback? onDecrement;

  final int minValue;

  /// Nome do item, para o leitor de tela anunciar "Arroz: diminuir" etc.
  final String? semanticsLabel;

  bool get _canDecrement => onDecrement != null && value > minValue;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _StepButton(
          icon: Icons.remove_rounded,
          tooltip: semanticsLabel == null
              ? 'Diminuir'
              : 'Diminuir $semanticsLabel',
          onPressed: _canDecrement ? onDecrement : null,
        ),
        SizedBox(
          // Largura fixa: o valor nao "pula" ao passar de 1 para 2 digitos.
          width: 40,
          child: Text(
            '$value',
            textAlign: TextAlign.center,
            style: AppTypography.titleMedium.copyWith(
              color: AppSemanticColors.textPrimary,
            ),
          ),
        ),
        _StepButton(
          icon: Icons.add_rounded,
          tooltip:
              semanticsLabel == null ? 'Aumentar' : 'Aumentar $semanticsLabel',
          onPressed: onIncrement,
        ),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;

    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon),
      iconSize: AppSizes.iconMd,
      visualDensity: VisualDensity.compact,
      style: IconButton.styleFrom(
        foregroundColor: enabled
            ? AppSemanticColors.actionPrimary
            : AppSemanticColors.textTertiary,
        backgroundColor: enabled
            ? AppSemanticColors.actionPrimarySubtle
            : AppSemanticColors.surfaceSubtle,
        minimumSize: const Size.square(AppSpacing.minTouchTarget),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
        ),
      ),
    );
  }
}
