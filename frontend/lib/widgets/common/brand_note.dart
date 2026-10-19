import 'package:flutter/material.dart';

import '../../theme/app_typography.dart';
import '../../theme/tokens/app_colors_semantic.dart';

/// Nota curta de marca, levemente rotacionada, com um tracinho de apoio.
///
/// Aparece em varios prototipos ("Mais liberdade para o seu dia",
/// "Pequenas decisoes hoje, uma vida mais leve amanha"). E um elemento de
/// tom de voz, nao um controle.
class BrandNote extends StatelessWidget {
  const BrandNote({
    super.key,
    required this.text,
    this.rotation = -0.06,
    this.maxWidth = 150,
    this.textAlign = TextAlign.left,
    this.accentColor,
  });

  final String text;

  /// Rotacao em radianos. Sutil de proposito: rotacoes fortes prejudicam
  /// a leitura.
  final double rotation;

  final double maxWidth;
  final TextAlign textAlign;

  /// Cor do tracinho de apoio. Padrao: azul de acao.
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: textAlign == TextAlign.left
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.end,
          children: [
            Text(
              text,
              textAlign: textAlign,
              style: AppTypography.bodySmall.copyWith(
                color: AppSemanticColors.textSecondary,
                fontStyle: FontStyle.italic,
                height: 1.42,
              ),
            ),
            const SizedBox(height: 6),
            ExcludeSemantics(
              child: Container(
                width: 34,
                height: 2,
                decoration: BoxDecoration(
                  color: accentColor ?? AppSemanticColors.actionPrimary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
