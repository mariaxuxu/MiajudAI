import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_typography.dart';
import '../../theme/tokens/app_colors_semantic.dart';

/// Confirmacao de acao destrutiva no visual do Design System.
///
/// [show] tem a mesma assinatura e o mesmo fluxo de `DeleteConfirmDialog.show`:
/// fecha o dialogo e SO ENTAO chama `onConfirm`. [showAwaiting] e a variante
/// das telas cujo dialogo legado espera a remocao terminar antes de fechar
/// (Parcelas e Gastos Fixos): o visual e o mesmo, so muda quando o dialogo fecha.
///
/// Existe ao lado do legado porque `DeleteConfirmDialog` ainda serve telas nao
/// redesenhadas; cada fase posterior troca o import e, no fim, o legado sai.
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
    return _show(
      context,
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      onConfirmPressed: (dialogContext) {
        Navigator.pop(dialogContext);
        onConfirm();
      },
    );
  }

  /// Chama [onConfirm], ESPERA ele terminar e so entao fecha o dialogo (se ele
  /// ainda estiver montado). Enquanto espera, o dialogo continua aberto; se
  /// [onConfirm] falhar, o erro segue adiante e o dialogo nao fecha.
  static Future<void> showAwaiting(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Deletar',
    required Future<void> Function() onConfirm,
  }) {
    return _show(
      context,
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      onConfirmPressed: (dialogContext) async {
        await onConfirm();
        if (dialogContext.mounted) Navigator.pop(dialogContext);
      },
    );
  }

  static Future<void> _show(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    required void Function(BuildContext dialogContext) onConfirmPressed,
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
                        onPressed: () => onConfirmPressed(dialogContext),
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
