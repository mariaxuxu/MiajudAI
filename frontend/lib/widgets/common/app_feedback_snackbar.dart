import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/tokens/app_colors_semantic.dart';

/// Feedback de sucesso/erro no visual do Design System.
///
/// Existe ao lado de `AppSnackBar` (legado) de proposito: aquele e usado por
/// telas ainda nao redesenhadas e por `manage_account_screen.dart`, entao nao
/// pode mudar de visual globalmente. Cada tela migrada passa a chamar este; o
/// legado sera aposentado quando nao restar nenhum uso.
///
/// A API e a mesma (`success`/`error` com contexto e mensagem), a duracao
/// (3s) e o comportamento flutuante tambem. Cor nunca e o unico sinal: cada
/// variante tem icone proprio e o texto da mensagem.
abstract final class AppFeedbackSnackBar {
  static void success(BuildContext context, String message) => _show(
        context,
        message,
        icon: Icons.check_rounded,
        accent: AppSemanticColors.feedbackSuccess,
        solid: AppSemanticColors.feedbackSuccessSolid,
        subtle: AppSemanticColors.feedbackSuccessSubtle,
      );

  static void error(BuildContext context, String message) => _show(
        context,
        message,
        icon: Icons.priority_high_rounded,
        accent: AppSemanticColors.feedbackError,
        solid: AppSemanticColors.feedbackErrorSolid,
        subtle: AppSemanticColors.feedbackErrorSubtle,
      );

  static void _show(
    BuildContext context,
    String message, {
    required IconData icon,
    required Color accent,
    required Color solid,
    required Color subtle,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(AppSpacing.defaultGap),
        elevation: 0,
        backgroundColor: subtle,
        duration: const Duration(seconds: 3),
        showCloseIcon: true,
        closeIconColor: AppSemanticColors.textSecondaryStrong,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: BorderSide(color: accent.withValues(alpha: 0.35)),
        ),
        content: Row(
          children: [
            ExcludeSemantics(
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(color: solid, shape: BoxShape.circle),
                child: Icon(
                  icon,
                  size: AppSizes.iconMd,
                  color: AppSemanticColors.onFeedbackSolid,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.itemGap),
            Expanded(
              child: Text(
                message,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppSemanticColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
