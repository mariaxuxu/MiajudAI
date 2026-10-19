import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/tokens/app_colors_semantic.dart';

/// Campo de busca do Design System, com lupa e botao de limpar.
///
/// Filtra no cliente: quem usa escuta [onChanged] e reduz a lista ja carregada.
/// Nao dispara requisicao nenhuma.
class PantrySearchField extends StatelessWidget {
  const PantrySearchField({
    super.key,
    required this.controller,
    required this.onChanged,
    this.hint = 'Buscar...',
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      style: AppTypography.bodyMedium.copyWith(
        color: AppSemanticColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.search_rounded, size: AppSizes.iconMd),
        prefixIconColor: AppSemanticColors.textSecondary,
        isDense: true,
        suffixIcon: ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (context, value, _) {
            if (value.text.isEmpty) return const SizedBox.shrink();
            return IconButton(
              tooltip: 'Limpar busca',
              onPressed: () {
                controller.clear();
                onChanged('');
              },
              icon: const Icon(Icons.close_rounded, size: AppSizes.iconMd),
            );
          },
        ),
      ),
    );
  }
}
