import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/tokens/app_colors_semantic.dart';
import 'agent_chat_scaffold.dart';

/// Aviso de erro do chat, acima do campo de mensagem.
///
/// O erro nao depende so de cor: leva icone e texto, e e anunciado por
/// leitores de tela assim que aparece.
class ChatErrorBanner extends StatelessWidget {
  const ChatErrorBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final gutter = AgentChatScaffold.gutterOf(context);

    return Semantics(
      liveRegion: true,
      container: true,
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.fromLTRB(gutter, 0, gutter, AppSpacing.labelGap),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.cardPadding,
          vertical: AppSpacing.itemGap,
        ),
        decoration: BoxDecoration(
          color: AppSemanticColors.feedbackErrorSubtle,
          borderRadius: BorderRadius.circular(AppRadius.control),
        ),
        child: Row(
          children: [
            const ExcludeSemantics(
              child: Icon(
                Icons.error_outline_rounded,
                size: AppSizes.iconMd,
                color: AppSemanticColors.onFeedbackError,
              ),
            ),
            const SizedBox(width: AppSpacing.labelGap),
            Expanded(
              child: Text(
                message,
                style: AppTypography.bodySmall.copyWith(
                  color: AppSemanticColors.onFeedbackError,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
