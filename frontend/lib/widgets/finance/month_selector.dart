import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/tokens/app_colors_semantic.dart';
import '../../theme/tokens/app_primitives.dart';

/// Barra de navegacao de mes: anterior, mes/ano e proximo.
///
/// Nao guarda estado nem decide o que "mudar de mes" significa: quem usa
/// recebe [onPrevious] e [onNext] e cuida do mes selecionado e do recarregamento.
///
/// O rotulo e uma regiao viva, entao leitores de tela anunciam o novo mes a
/// cada troca.
class MonthSelector extends StatelessWidget {
  const MonthSelector({
    super.key,
    required this.month,
    required this.onPrevious,
    required this.onNext,
  });

  final DateTime month;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  /// "Setembro de 2026". Requer `initializeDateFormatting('pt_BR')`, feito em
  /// `main.dart`.
  static String labelFor(DateTime month) {
    final text = DateFormat("MMMM 'de' y", 'pt_BR').format(month);
    return text.isEmpty ? text : '${text[0].toUpperCase()}${text.substring(1)}';
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppSemanticColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppSemanticColors.border),
        boxShadow: AppPrimitives.shadowSm,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.labelGap),
        child: Row(
          children: [
            _StepButton(
              icon: Icons.chevron_left_rounded,
              tooltip: 'Mês anterior',
              onPressed: onPrevious,
            ),
            Expanded(
              child: Semantics(
                liveRegion: true,
                child: Text(
                  labelFor(month),
                  textAlign: TextAlign.center,
                  style: AppTypography.titleMedium.copyWith(
                    color: AppSemanticColors.textPrimary,
                  ),
                ),
              ),
            ),
            _StepButton(
              icon: Icons.chevron_right_rounded,
              tooltip: 'Próximo mês',
              onPressed: onNext,
            ),
          ],
        ),
      ),
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
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon),
      style: IconButton.styleFrom(
        fixedSize: const Size.square(AppSpacing.minTouchTarget),
        backgroundColor: AppSemanticColors.actionPrimarySubtle,
        foregroundColor: AppSemanticColors.actionPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
        ),
      ),
    );
  }
}
