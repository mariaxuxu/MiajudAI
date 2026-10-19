import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/tokens/app_colors_semantic.dart';

/// Navegacao de mes para dentro de um card navy (`BalanceHeroCard.control`):
/// anterior, mes/ano e proximo, numa pilula escura translucida.
///
/// E o irmao escuro do `MonthSelector` (barra clara, para fundos claros). Nao
/// guarda estado nem decide o que "mudar de mes" significa: quem usa recebe
/// [onPrevious] e [onNext]. O [label] chega pronto ("Setembro 2026").
///
/// O rotulo e uma regiao viva, entao leitores de tela anunciam o novo mes a
/// cada troca. Os dois botoes tem alvo de toque de 48dp.
class HeroMonthSwitcher extends StatelessWidget {
  const HeroMonthSwitcher({
    super.key,
    required this.label,
    required this.onPrevious,
    required this.onNext,
  });

  final String label;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        // Mais escuro que o card: destaca a pilula sem depender de borda.
        color: Colors.black.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(AppRadius.control),
      ),
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
                label,
                textAlign: TextAlign.center,
                style: AppTypography.titleSmall.copyWith(
                  color: AppSemanticColors.onSurfaceStrong,
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
        foregroundColor: AppSemanticColors.onSurfaceStrong,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
        ),
      ),
    );
  }
}
