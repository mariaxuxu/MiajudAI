import 'package:flutter/material.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_typography.dart';
import '../../theme/tokens/app_colors_semantic.dart';

class LogoutDialog {
  static Future<void> show(
    BuildContext context, {
    required VoidCallback onConfirm,
  }) {
    return showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      // O dialogo vive numa rota propria, fora do Theme local da tela; o tema
      // do Design System e reaplicado explicitamente.
      builder: (dialogContext) => Theme(
        data: AppTheme.light,
        child: Dialog(
          backgroundColor: AppSemanticColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sheet),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: AppSemanticColors.feedbackErrorSubtle,
                    shape: BoxShape.circle,
                  ),
                  child: const ExcludeSemantics(
                    child: Icon(
                      Icons.logout_rounded,
                      color: AppSemanticColors.onFeedbackError,
                      size: 26,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.defaultGap),
                Semantics(
                  header: true,
                  child: Text(
                    'Sair da conta?',
                    style: AppTypography.headlineSmall.copyWith(
                      color: AppSemanticColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.labelGap),
                Text(
                  'Você será desconectado e precisará entrar novamente.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppSemanticColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.blockGap),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(dialogContext),
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
                        // Acao destrutiva: fundo vermelho solido (AA com branco).
                        style: FilledButton.styleFrom(
                          backgroundColor: AppSemanticColors.feedbackErrorSolid,
                          foregroundColor: AppSemanticColors.onFeedbackSolid,
                        ),
                        child: const Text('Sair'),
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
