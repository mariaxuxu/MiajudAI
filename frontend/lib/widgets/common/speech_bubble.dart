import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/tokens/app_colors_semantic.dart';
import '../../theme/tokens/app_primitives.dart';

/// Balao de fala curto com um tracinho de apoio.
///
/// Acompanha a ilustracao de um agente (home e chat) com uma frase de tom de
/// voz. E texto de marca, nao um controle: nao recebe toque.
class SpeechBubble extends StatelessWidget {
  const SpeechBubble({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppSemanticColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppPrimitives.shadowMd,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: AppTypography.labelSmall.copyWith(
              color: AppSemanticColors.textSecondaryStrong,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 6),
          ExcludeSemantics(
            child: Container(
              width: 28,
              height: 2,
              decoration: BoxDecoration(
                color: AppSemanticColors.actionPrimary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
