import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/tokens/app_colors_semantic.dart';

/// Uma opcao de humor: o [value] que a tela guarda e envia, o [emoji] e o
/// [label] que o usuario le.
class MoodOption {
  const MoodOption({
    required this.value,
    required this.emoji,
    required this.label,
  });

  final String value;
  final String emoji;
  final String label;
}

/// Escolha de UM humor entre [options], em blocos lado a lado.
///
/// So apresenta e avisa: [selected] e as [options] chegam de fora e a troca sai
/// por [onChanged] com o `value` tocado. Quem usa continua dono da regra (quais
/// humores existem, qual e o padrao, o que se envia).
///
/// A selecao nunca depende so da cor: o bloco escolhido ganha contorno grosso,
/// fundo azul e rotulo em negrito, e o leitor de tela o anuncia como marcado,
/// num grupo de escolha unica.
class MoodSelector extends StatelessWidget {
  const MoodSelector({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  final List<MoodOption> options;
  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < options.length; i++) ...[
            if (i > 0) const SizedBox(width: AppSpacing.itemGap),
            Expanded(
              child: _MoodTile(
                option: options[i],
                isSelected: options[i].value == selected,
                onTap: () => onChanged(options[i].value),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MoodTile extends StatelessWidget {
  const _MoodTile({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  final MoodOption option;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(AppRadius.control);

    return Semantics(
      button: true,
      inMutuallyExclusiveGroup: true,
      checked: isSelected,
      label: option.label,
      onTap: onTap,
      excludeSemantics: true,
      child: Material(
        color: isSelected
            ? AppSemanticColors.actionPrimarySubtle
            : AppSemanticColors.surfaceSubtle,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius,
          // Largura fixa nos dois estados: escolher nao empurra o layout.
          side: BorderSide(
            color: isSelected
                ? AppSemanticColors.actionPrimary
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          focusColor: AppSemanticColors.actionPrimary.withValues(alpha: 0.12),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.labelGap,
              vertical: AppSpacing.itemGap,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  option.emoji,
                  style: const TextStyle(fontSize: 28, height: 1.2),
                ),
                const SizedBox(height: AppSpacing.labelGap / 2),
                Text(
                  option.label,
                  textAlign: TextAlign.center,
                  style: AppTypography.labelMedium.copyWith(
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? AppSemanticColors.actionPrimary
                        : AppSemanticColors.textSecondaryStrong,
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
