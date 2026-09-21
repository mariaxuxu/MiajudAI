import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/tokens/app_colors_semantic.dart';

/// Cabecalho das telas de modulo: voltar, titulo, subtitulo e acoes.
///
/// O botao de voltar so dispara [onBack]; quem usa decide o que "voltar"
/// significa. Todos os alvos de toque tem 48dp.
class ModuleScreenHeader extends StatelessWidget {
  const ModuleScreenHeader({
    super.key,
    required this.title,
    required this.onBack,
    this.subtitle,
    this.actions = const [],
  });

  final String title;
  final String? subtitle;
  final VoidCallback onBack;

  /// Acoes a direita (icones de 48dp).
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final subtitle = this.subtitle;

    return Row(
      children: [
        IconButton(
          tooltip: 'Voltar',
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back_rounded),
          color: AppSemanticColors.textPrimary,
        ),
        const SizedBox(width: AppSpacing.labelGap),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                child: Text(
                  title,
                  style: AppTypography.headlineMedium.copyWith(
                    color: AppSemanticColors.textPrimary,
                  ),
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppSemanticColors.textSecondary,
                  ),
                ),
            ],
          ),
        ),
        // Respiro entre o titulo (que pode quebrar) e as acoes.
        for (final action in actions) ...[
          const SizedBox(width: AppSpacing.labelGap),
          action,
        ],
      ],
    );
  }
}
