import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/tokens/app_colors_semantic.dart';
import '../../theme/tokens/app_primitives.dart';

/// Peso visual da chamada para acao de um [EmptyStateCard].
enum EmptyStateActionStyle {
  /// Contorno azul: acao secundaria (padrao).
  outlined,

  /// Preenchida: a acao principal da tela vazia.
  filled,
}

/// Card de estado vazio: arte decorativa, titulo, descricao e, opcionalmente,
/// uma chamada para acao.
///
/// A [art] e ornamental (sai da arvore de semantica): o titulo e a descricao
/// carregam o significado. A acao, quando presente, e apenas um segundo
/// caminho para algo que a tela ja oferece; quem usa passa o [onAction].
class EmptyStateCard extends StatelessWidget {
  const EmptyStateCard({
    super.key,
    required this.art,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.actionStyle = EmptyStateActionStyle.outlined,
  }) : assert(
          (actionLabel == null) == (onAction == null),
          'actionLabel e onAction andam juntos',
        );

  final Widget art;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final EmptyStateActionStyle actionStyle;

  static final ButtonStyle _actionStyle = ButtonStyle(
    foregroundColor: const WidgetStatePropertyAll(
      AppSemanticColors.actionPrimary,
    ),
    side: WidgetStateProperty.resolveWith((states) {
      // Foco sempre visivel: a borda engrossa (WCAG 2.2 AA, 2.4.11).
      final focused = states.contains(WidgetState.focused);
      return BorderSide(
        color: AppSemanticColors.actionPrimary,
        width: focused ? 3 : 1.5,
      );
    }),
  );

  @override
  Widget build(BuildContext context) {
    final actionLabel = this.actionLabel;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.blockGap),
      decoration: BoxDecoration(
        color: AppSemanticColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppPrimitives.shadowSm,
      ),
      child: Column(
        children: [
          ExcludeSemantics(child: art),
          const SizedBox(height: AppSpacing.defaultGap),
          Semantics(
            header: true,
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: AppTypography.headlineSmall.copyWith(
                color: AppSemanticColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.labelGap),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium.copyWith(
              color: AppSemanticColors.textSecondary,
            ),
          ),
          if (actionLabel != null) ...[
            const SizedBox(height: AppSpacing.blockGap),
            if (actionStyle == EmptyStateActionStyle.filled)
              FilledButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add_rounded, size: AppSizes.iconLg),
                label: Text(actionLabel),
              )
            else
              OutlinedButton.icon(
                onPressed: onAction,
                style: _actionStyle,
                icon: const Icon(Icons.add_rounded, size: AppSizes.iconLg),
                label: Text(actionLabel),
              ),
          ],
        ],
      ),
    );
  }
}
