import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/tokens/app_colors_semantic.dart';
import '../brand/app_logo.dart';
import '../common/brand_note.dart';

/// Cabecalho das telas de autenticacao (Login e Signup).
///
/// Linha superior com o botao de voltar e a [BrandNote], logo alinhada a
/// esquerda e, abaixo, titulo e subtitulo. Nao decide para onde "voltar":
/// isso continua sendo responsabilidade de cada tela, via [onBack].
class AuthScreenHeader extends StatelessWidget {
  const AuthScreenHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.noteText,
    required this.onBack,
    this.logoHeight = 50,
  });

  final String title;
  final String subtitle;

  /// Frase curta de marca exibida, levemente inclinada, no canto superior.
  final String noteText;

  final VoidCallback onBack;

  /// Altura do simbolo da marca.
  final double logoHeight;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // O glifo fica rente ao gutter; a area de toque continua 48x48.
            IconButton(
              tooltip: 'Voltar',
              onPressed: onBack,
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: AppSemanticColors.textPrimary,
              ),
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: AppSpacing.minTouchTarget,
                minHeight: AppSpacing.minTouchTarget,
              ),
            ),
            const Spacer(),
            BrandNote(
              text: noteText,
              textAlign: TextAlign.right,
              rotation: -0.07,
              maxWidth: 132,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.itemGap),
        AppLogo(markHeight: logoHeight),
        const SizedBox(height: AppSpacing.blockGap),
        Semantics(
          header: true,
          child: Text(
            title,
            style: AppTypography.headlineLarge.copyWith(
              color: AppSemanticColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: AppTypography.bodyMedium.copyWith(
            color: AppSemanticColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
