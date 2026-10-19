import 'package:flutter/material.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_typography.dart';
import '../../theme/tokens/app_colors_semantic.dart';
import '../common/app_primary_button.dart';

class UnderConstructionDialog extends StatelessWidget {
  final String agentName;
  final String agentRole;
  final String imagePath;
  final Color agentColor;

  const UnderConstructionDialog({
    super.key,
    required this.agentName,
    required this.agentRole,
    required this.imagePath,
    required this.agentColor,
  });

  static Future<void> show(
    BuildContext context, {
    required String agentName,
    required String agentRole,
    required String imagePath,
    required Color agentColor,
  }) {
    return showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      // O dialogo vive numa rota propria, fora do Theme local da tela; o tema
      // do Design System e reaplicado explicitamente.
      builder: (_) => Theme(
        data: AppTheme.light,
        child: UnderConstructionDialog(
          agentName: agentName,
          agentRole: agentRole,
          imagePath: imagePath,
          agentColor: agentColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppSemanticColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.sheet),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Avatar do agente
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: agentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.card),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.contain,
                  excludeFromSemantics: true,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Selo "em construcao": icone + texto, nunca so cor.
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: AppSemanticColors.feedbackWarningSubtle,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const ExcludeSemantics(
                    child: Icon(
                      Icons.construction_outlined,
                      size: 14,
                      color: AppSemanticColors.onFeedbackWarning,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Em construção',
                    style: AppTypography.labelSmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppSemanticColors.onFeedbackWarning,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.defaultGap),

            Semantics(
              header: true,
              child: Text(
                agentName,
                style: AppTypography.headlineMedium.copyWith(
                  color: AppSemanticColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              agentRole,
              style: AppTypography.labelMedium.copyWith(
                color: AppSemanticColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.itemGap),
            Text(
              'Estamos construindo algo incrível!\nEm breve este agente estará disponível para te ajudar.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(
                color: AppSemanticColors.textSecondary,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 28),

            AppPrimaryButton(
              label: 'Entendido',
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
