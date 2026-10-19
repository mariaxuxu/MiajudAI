import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/tokens/app_colors_semantic.dart';

/// Menu "mais opcoes" do chat, com a unica acao que a tela oferece:
/// limpar a conversa.
///
/// So dispara [onClear]; o que "limpar" faz e de quem usa.
class ChatOptionsMenu extends StatelessWidget {
  const ChatOptionsMenu({super.key, required this.onClear});

  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<void>(
      tooltip: 'Mais opções',
      icon: const Icon(Icons.more_vert_rounded),
      iconColor: AppSemanticColors.textPrimary,
      color: AppSemanticColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.control),
        side: const BorderSide(color: AppSemanticColors.border),
      ),
      itemBuilder: (_) => [
        PopupMenuItem<void>(
          onTap: onClear,
          child: Row(
            children: [
              const Icon(
                Icons.delete_sweep_outlined,
                size: AppSizes.iconMd,
                color: AppSemanticColors.textSecondaryStrong,
              ),
              const SizedBox(width: AppSpacing.itemGap),
              Text(
                'Limpar conversa',
                style: AppTypography.bodyLarge.copyWith(
                  color: AppSemanticColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
