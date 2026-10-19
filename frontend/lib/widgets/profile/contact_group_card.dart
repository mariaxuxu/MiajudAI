import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/tokens/app_colors_semantic.dart';
import '../../theme/tokens/app_primitives.dart';
import 'profile_section_card.dart';

/// Bloco de um contato de emergencia: titulo (com dica opcional), Nome e
/// Telefone num contorno unico e a opcao "Nao tenho".
///
/// So apresenta. [onEditName]/[onEditPhone] nulos deixam a linha sem acao (e
/// sem seta): e o estado do contato marcado como "Nao tenho". Quem usa decide
/// o que marcar/editar significa; [onToggleNoContact] recebe o novo valor.
class ContactGroupCard extends StatelessWidget {
  const ContactGroupCard({
    super.key,
    required this.title,
    this.hint,
    required this.name,
    required this.phone,
    required this.noContact,
    required this.onToggleNoContact,
    this.onEditName,
    this.onEditPhone,
  });

  final String title;

  /// Dica ao lado do titulo, ex.: "(preferencial, ex.: Mae)".
  final String? hint;

  final String name;
  final String phone;
  final bool noContact;
  final ValueChanged<bool> onToggleNoContact;
  final VoidCallback? onEditName;
  final VoidCallback? onEditPhone;

  @override
  Widget build(BuildContext context) {
    final hint = this.hint;
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
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Semantics(
                header: true,
                child: Text.rich(
                  TextSpan(
                    text: title,
                    style: AppTypography.titleMedium.copyWith(
                      color: AppSemanticColors.textPrimary,
                    ),
                    children: [
                      if (hint != null)
                        TextSpan(
                          text: '  $hint',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppSemanticColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.itemGap),
              DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.control),
                  border: Border.all(color: AppSemanticColors.border),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.control - 1),
                  child: Column(
                    children: [
                      ProfileFieldRow(
                        label: 'Nome',
                        value: name,
                        onTap: onEditName,
                      ),
                      const Divider(height: 1, thickness: 1),
                      ProfileFieldRow(
                        label: 'Telefone',
                        value: phone,
                        onTap: onEditPhone,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.labelGap),
              MergeSemantics(
                child: InkWell(
                  onTap: () => onToggleNoContact(!noContact),
                  borderRadius: BorderRadius.circular(AppRadius.chip),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      minHeight: AppSpacing.minTouchTarget,
                    ),
                    child: Row(
                      children: [
                        Checkbox(
                          value: noContact,
                          onChanged: (v) => onToggleNoContact(v ?? false),
                        ),
                        Expanded(
                          child: Text(
                            'Não tenho',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppSemanticColors.textSecondaryStrong,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Aviso informativo do perfil (icone de informacao, titulo e texto).
///
/// Conteudo estatico: nao e tocavel e e lido como um unico bloco.
class ProfileInfoCard extends StatelessWidget {
  const ProfileInfoCard(
      {super.key, required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(
          color: AppSemanticColors.actionPrimarySubtle,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: AppTone.blue.surface),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExcludeSemantics(
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTone.blue.surface,
                  borderRadius: BorderRadius.circular(AppRadius.control),
                ),
                child: Icon(
                  Icons.info_outline_rounded,
                  size: AppSizes.iconLg,
                  color: AppTone.blue.foreground,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.itemGap),
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
                    message,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppSemanticColors.textSecondaryStrong,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
