import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/tokens/app_colors_semantic.dart';

/// Aviso de busca sem resultado, compartilhado pelas telas de Despensa e
/// Catalogo. Nao e um estado vazio (que fala da despensa inteira): e so o
/// eco de um filtro que nao casou com nada.
class NoResultsNote extends StatelessWidget {
  const NoResultsNote({super.key, required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sectionGap),
      child: Text(
        'Nenhum item encontrado para "$query".',
        textAlign: TextAlign.center,
        style: AppTypography.bodyMedium.copyWith(
          color: AppSemanticColors.textSecondary,
        ),
      ),
    );
  }
}
