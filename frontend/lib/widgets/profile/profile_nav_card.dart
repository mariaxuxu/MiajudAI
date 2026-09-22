import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/tokens/app_colors_semantic.dart';
import '../../theme/tokens/app_primitives.dart';

/// Card de navegacao do hub de perfil: icone em bloco tonal, titulo, apoio e
/// seta. Toda a superficie e o alvo de toque (ripple, foco e semantica de
/// botao); o destino e de quem usa, via [onTap].
///
/// Diferente de `QuickActionCard` (celula vertical da grade da home), este e
/// uma linha de largura total.
class ProfileNavCard extends StatelessWidget {
  const ProfileNavCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
    this.tone = AppTone.blue,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;
  final AppTone tone;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadius.card);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: AppPrimitives.shadowSm,
      ),
      child: Material(
        color: AppSemanticColors.surface,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: MergeSemantics(
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.cardPadding),
              child: Row(
                children: [
                  ExcludeSemantics(
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: tone.surface,
                        borderRadius: BorderRadius.circular(AppRadius.control),
                      ),
                      child: Icon(
                        icon,
                        size: AppSizes.iconLg,
                        color: tone.foreground,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.defaultGap),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppTypography.titleMedium.copyWith(
                            color: AppSemanticColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          description,
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppSemanticColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.labelGap),
                  const ExcludeSemantics(
                    child: Icon(
                      Icons.chevron_right_rounded,
                      size: AppSizes.iconLg,
                      color: AppSemanticColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
