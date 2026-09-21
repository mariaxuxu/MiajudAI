import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_typography.dart';
import '../../theme/tokens/app_colors_semantic.dart';

/// Confirmacao de acao destrutiva no visual do Design System.
///
/// Mesma assinatura e mesmo fluxo de `DeleteConfirmDialog.show`: fecha o
/// dialogo e SO ENTAO chama [onConfirm]. Existe ao lado do legado porque
/// `DeleteConfirmDialog` ainda serve telas nao redesenhadas; cada fase
/// posterior troca o import e, no fim, o legado sai.
///
/// Um dialogo e uma rota nova e nao herda o `Theme` local da tela, entao o
/// [AppTheme] e reaplicado aqui.
abstract final class AppConfirmDialog {
  static Future<void> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Deletar',
    required VoidCallback onConfirm,
  }) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (dialogContext) => Theme(
        data: AppTheme.light,
        child: Dialog(
          backgroundColor: AppSemanticColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sheet),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenGutter,
              AppSpacing.sectionGap,
              AppSpacing.screenGutter,
              AppSpacing.defaultGap + 4,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ExcludeSemantics(
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      color: AppSemanticColors.feedbackErrorSubtle,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      size: AppSizes.iconLg + 2,
                      color: AppSemanticColors.onFeedbackError,
                    ),
                  ),
                ),
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
                    color: AppSemanticColors.textSecondaryStrong,
                  ),
                ),
                const SizedBox(height: AppSpacing.blockGap),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        // Padding menor que o do tema: em 320dp cada botao
                        // tem ~90dp e o rotulo precisa caber sem quebrar.
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.labelGap,
                          ),
                        ),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.itemGap),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                          onConfirm();
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: AppSemanticColors.feedbackErrorSolid,
                          foregroundColor: AppSemanticColors.onFeedbackSolid,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.labelGap,
                          ),
                        ),
                        child: Text(confirmLabel),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
