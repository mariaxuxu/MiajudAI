import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/tokens/app_colors_semantic.dart';

/// Abas em pilulas, ligadas a um [TabController] que quem usa ja possui.
///
/// So apresenta: quem usa continua dono do controller e do `TabBarView`, entao
/// o deslize entre abas e o conteudo de cada uma seguem como estavam. Tocar em
/// uma pilula apenas chama `controller.animateTo`. O estado selecionado acompanha
/// o controller, inclusive quando a aba muda por deslize.
///
/// As pilulas rolam na horizontal quando nao cabem (tela estreita ou texto
/// ampliado) e a selecionada rola para dentro da vista. Cada uma tem alvo de
/// toque de 48dp e diz "aba N de M" e se esta selecionada para leitores de
/// tela; a selecao tambem aparece por contorno e texto, nao so por cor.
class AppSegmentedTabs extends StatelessWidget {
  const AppSegmentedTabs({
    super.key,
    required this.controller,
    required this.labels,
  });

  final TabController controller;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (var i = 0; i < labels.length; i++) ...[
                if (i > 0) const SizedBox(width: AppSpacing.labelGap),
                _Pill(
                  label: labels[i],
                  semanticLabel:
                      '${labels[i]}, aba ${i + 1} de ${labels.length}',
                  selected: controller.index == i,
                  onTap: () => controller.animateTo(i),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _Pill extends StatefulWidget {
  const _Pill({
    required this.label,
    required this.semanticLabel,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String semanticLabel;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_Pill> createState() => _PillState();
}

class _PillState extends State<_Pill> {
  /// Altura visual da pilula; a area de toque tem 48dp.
  static const double _height = 40;

  @override
  void didUpdateWidget(_Pill oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A aba pode mudar por deslize: traz a pilula selecionada para a vista.
    if (widget.selected && !oldWidget.selected) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Scrollable.ensureVisible(
          context,
          alignment: 0.5,
          duration: const Duration(milliseconds: 200),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final selected = widget.selected;
    final decoration = BoxDecoration(
      color: selected
          ? AppSemanticColors.actionPrimarySubtle
          : AppSemanticColors.surfaceSubtle,
      borderRadius: BorderRadius.circular(AppRadius.control),
      border: Border.all(
        color: selected ? AppSemanticColors.actionPrimary : Colors.transparent,
        width: 1.5,
      ),
    );

    return Semantics(
      button: true,
      selected: selected,
      label: widget.semanticLabel,
      excludeSemantics: true,
      onTap: widget.onTap,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(AppRadius.control),
        child: SizedBox(
          height: AppSpacing.minTouchTarget,
          child: Center(
            child: Container(
              height: _height,
              // 10 (fora do grid de 4) e o maximo para as quatro abas de
              // Despesas caberem em 390 sem cortar a ultima.
              padding: const EdgeInsets.symmetric(horizontal: 10),
              alignment: Alignment.center,
              decoration: decoration,
              child: Text(
                widget.label,
                style: AppTypography.labelMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: selected
                      ? AppSemanticColors.actionPrimaryHover
                      : AppSemanticColors.textSecondaryStrong,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
