import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/tokens/app_colors_semantic.dart';

/// Uma categoria selecionavel: o [value] que a tela guarda e envia, o [label]
/// que o usuario le e o [icon] que a ilustra.
class CategoryOption {
  const CategoryOption({
    required this.value,
    required this.label,
    required this.icon,
  });

  final String value;
  final String label;
  final IconData icon;
}

/// Escolha de VARIAS categorias entre [options], em chips que quebram de linha.
///
/// So apresenta e avisa: o conjunto [selected] e as [options] chegam de fora e
/// cada toque sai por [onChanged] com o `value` e se ele passou a estar
/// marcado. Quem usa continua dono da regra (quais categorias existem, em que
/// ordem entram na lista enviada).
///
/// A selecao nunca depende so da cor: o chip marcado troca o icone da categoria
/// por um "check" e ganha contorno e fundo azuis.
class CategoryChips extends StatelessWidget {
  const CategoryChips({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  final List<CategoryOption> options;
  final Set<String> selected;
  final void Function(String value, bool isSelected) onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.labelGap,
      runSpacing: AppSpacing.labelGap,
      children: [
        for (final option in options)
          _CategoryChip(
            option: option,
            isSelected: selected.contains(option.value),
            onSelected: (value) => onChanged(option.value, value),
          ),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.option,
    required this.isSelected,
    required this.onSelected,
  });

  final CategoryOption option;
  final bool isSelected;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    final color = isSelected
        ? AppSemanticColors.actionPrimary
        : AppSemanticColors.textSecondaryStrong;

    return FilterChip(
      label: Text(option.label),
      // O "check" e o proprio icone do chip marcado (o do Material desenharia
      // um disco cinza por cima do icone da categoria).
      avatar: Icon(
        isSelected ? Icons.check_rounded : option.icon,
        size: AppSizes.iconMd,
      ),
      selected: isSelected,
      onSelected: onSelected,
      showCheckmark: false,
      backgroundColor: AppSemanticColors.surface,
      selectedColor: AppSemanticColors.actionPrimarySubtle,
      side: BorderSide(
        color: isSelected
            ? AppSemanticColors.actionPrimary
            : AppSemanticColors.borderStrong,
        width: isSelected ? 1.5 : 1,
      ),
      shape: const StadiumBorder(),
      iconTheme: IconThemeData(color: color),
      labelStyle: AppTypography.labelMedium.copyWith(
        color: color,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.labelGap),
      labelPadding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.labelGap / 2),
    );
  }
}
