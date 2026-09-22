import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/tokens/app_colors_semantic.dart';

/// Campo de selecao de formulario do Design System: rotulo acima e
/// `DropdownButtonFormField` abaixo, com o mesmo visual de `AppFormField`.
///
/// Quem usa continua dono do valor selecionado: [onChanged] recebe a escolha e
/// a tela decide o que fazer com ela. Nada aqui filtra ou reordena [items].
class AppFormDropdown<T> extends StatelessWidget {
  const AppFormDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExcludeSemantics(
          child: Text(
            label,
            style: AppTypography.labelMedium.copyWith(
              color: AppSemanticColors.textSecondaryStrong,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.labelGap),
        Semantics(
          label: label,
          // Por padrao o Flutter alarga o menu em 16dp a esquerda e 24dp a
          // direita do campo; `alignedDropdown` o alinha ao campo.
          child: ButtonTheme(
            alignedDropdown: true,
            child: DropdownButtonFormField<T>(
              initialValue: value,
              onChanged: onChanged,
              items: items,
              // Itens longos (ex.: nome de conta + saldo) quebram em vez de
              // estourar a largura.
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded),
              borderRadius: BorderRadius.circular(AppRadius.control),
              dropdownColor: AppSemanticColors.surface,
              style: AppTypography.bodyMedium.copyWith(
                color: AppSemanticColors.textPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
