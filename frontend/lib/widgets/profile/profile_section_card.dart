import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/tokens/app_colors_semantic.dart';
import '../../theme/tokens/app_primitives.dart';

/// Cartao branco de uma secao de dados: cabecalho (icone tonal, titulo e apoio)
/// e, abaixo, as linhas ([children], normalmente `ProfileFieldRow`) separadas
/// por divisores.
///
/// So apresenta: nao le nem grava dado algum.
class ProfileSectionCard extends StatelessWidget {
  const ProfileSectionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.children,
    this.tone = AppTone.blue,
  });

  final IconData icon;
  final String title;
  final String description;
  final List<Widget> children;
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
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
                    child: Semantics(
                      container: true,
                      header: true,
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
                  ),
                ],
              ),
            ),
            for (final child in children) ...[
              const Divider(height: 1, thickness: 1),
              child,
            ],
          ],
        ),
      ),
    );
  }
}

/// Linha rotulo + valor de um dado do perfil.
///
/// Com [onTap] a linha inteira e um botao (>= 48dp) e ganha a seta; sem ele e
/// so leitura, sem seta (a seta nunca promete uma acao que nao existe).
/// [trailingIcon] e um ornamento opcional (lapis, calendario) e nao muda a
/// semantica: quem le a tela ouve "rotulo, valor".
///
/// Nao tem fundo nem borda proprios: quem a contem (cartao de secao, bloco de
/// contato) fornece a superficie.
class ProfileFieldRow extends StatelessWidget {
  const ProfileFieldRow({
    super.key,
    required this.label,
    required this.value,
    this.onTap,
    this.trailingIcon,
  });

  final String label;
  final String value;
  final VoidCallback? onTap;
  final IconData? trailingIcon;

  @override
  Widget build(BuildContext context) {
    final onTap = this.onTap;
    final trailingIcon = this.trailingIcon;

    final content = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: AppSpacing.minTouchTarget),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.cardPadding,
          vertical: AppSpacing.itemGap,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppSemanticColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppSemanticColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            if (trailingIcon != null) ...[
              const SizedBox(width: AppSpacing.labelGap),
              ExcludeSemantics(
                child: Icon(
                  trailingIcon,
                  size: AppSizes.iconMd,
                  color: AppSemanticColors.actionPrimary,
                ),
              ),
            ],
            if (onTap != null) ...[
              const SizedBox(width: AppSpacing.labelGap),
              const ExcludeSemantics(
                child: Icon(
                  Icons.chevron_right_rounded,
                  size: AppSizes.iconLg,
                  color: AppSemanticColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );

    return MergeSemantics(
      child: onTap == null
          ? content
          : Material(
              type: MaterialType.transparency,
              child: InkWell(onTap: onTap, child: content),
            ),
    );
  }
}
