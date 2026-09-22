import 'package:flutter/material.dart';

import '../../theme/app_typography.dart';
import '../../theme/tokens/app_colors_semantic.dart';

/// Como a marca MiAjudAI e apresentada.
enum AppLogoVariant {
  /// Apenas o simbolo (casa + robo).
  mark,

  /// Simbolo acima do nome, empilhados. Usado nas telas de entrada.
  lockup,

  /// Apenas o nome. Usado em headers compactos.
  wordmark,
}

/// Marca oficial do MiAjudAI.
///
/// O simbolo vem de `assets/images/brand/logo_mark.png`, derivado de
/// `referencesForNewDesign/logoNova.png` (fundo navy removido, wordmark
/// branco descartado). O nome e renderizado como TEXTO, e nao como imagem,
/// por tres motivos: o wordmark do PNG original e branco e sumiria sobre o
/// fundo claro; texto acompanha o aumento de fonte do sistema; e leitores de
/// tela conseguem anuncia-lo.
class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.variant = AppLogoVariant.lockup,
    this.markHeight = 64,
    this.wordmarkFontSize = 26,
  });

  static const String markAsset = 'assets/images/brand/logo_mark.png';

  /// Proporcao do PNG da marca (587 x 347).
  static const double markAspectRatio = 587 / 347;

  final AppLogoVariant variant;

  /// Altura do simbolo, em pixels logicos.
  final double markHeight;

  /// Tamanho do nome. Ignorado quando [variant] e [AppLogoVariant.mark].
  final double wordmarkFontSize;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'MiAjudAI',
      image: variant != AppLogoVariant.wordmark,
      child: ExcludeSemantics(
        child: switch (variant) {
          AppLogoVariant.mark => _buildMark(),
          AppLogoVariant.wordmark => _buildWordmark(context),
          AppLogoVariant.lockup => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildMark(),
                const SizedBox(height: 10),
                _buildWordmark(context),
              ],
            ),
        },
      ),
    );
  }

  Widget _buildMark() {
    return Image.asset(
      markAsset,
      height: markHeight,
      width: markHeight * markAspectRatio,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
    );
  }

  Widget _buildWordmark(BuildContext context) {
    final base = AppTypography.displayMedium.copyWith(
      fontSize: wordmarkFontSize,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.8,
      height: 1.1,
    );

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: 'MiAjud',
            style: base.copyWith(color: AppSemanticColors.textPrimary),
          ),
          TextSpan(
            text: 'AI',
            style: base.copyWith(color: AppSemanticColors.actionPrimary),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
