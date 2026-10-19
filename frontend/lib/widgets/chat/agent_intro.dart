import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/tokens/app_colors_semantic.dart';
import '../common/cropped_asset_image.dart';
import '../common/speech_bubble.dart';

/// Apresentacao do agente no estado inicial do chat: ilustracao num circulo,
/// balao de fala, titulo e subtitulo.
///
/// Puramente informativo; nada aqui recebe toque.
class AgentIntro extends StatelessWidget {
  const AgentIntro({
    super.key,
    required this.agent,
    required this.title,
    required this.subtitle,
    required this.note,
  });

  final AppAgent agent;
  final String title;
  final String subtitle;

  /// Frase de tom de voz mostrada no balao.
  final String note;

  static const double _circle = 128;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: _circle,
          child: LayoutBuilder(
            builder: (context, constraints) {
              // O balao usa o espaco ao lado do circulo; em telas estreitas
              // encolhe ate um minimo em vez de cobrir a ilustracao.
              final side = (constraints.maxWidth - _circle) / 2;
              final bubbleWidth = math.min(120.0, math.max(88.0, side));

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Center(child: _buildArt()),
                  Positioned(
                    top: -4,
                    right: 0,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: bubbleWidth),
                      child: SpeechBubble(text: note),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.defaultGap),
        Semantics(
          header: true,
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: AppTypography.headlineMedium.copyWith(
              color: AppSemanticColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.labelGap),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: AppTypography.bodyMedium.copyWith(
            color: AppSemanticColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildArt() {
    return ExcludeSemantics(
      child: Container(
        width: _circle,
        height: _circle,
        decoration: BoxDecoration(
          color: agent.surface,
          shape: BoxShape.circle,
        ),
        child: ClipOval(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(height: _circle * 0.9, child: _art()),
          ),
        ),
      ),
    );
  }

  Widget _art() {
    switch (agent) {
      case AppAgent.luna:
        // luna.png (2048x2048): o gato e a mala ocupam x 0,159-0,804 e
        // y 0,074-0,958. Recorte de 70% x 92% com folga em volta da arte.
        return CroppedAssetImage(
          asset: agent.assetPath,
          assetSize: const Size(2048, 2048),
          widthFactor: 0.70,
          heightFactor: 0.92,
          anchor: const Alignment(-0.1, 0.25),
        );
      case AppAgent.otto:
      case AppAgent.tina:
        return Image.asset(
          agent.assetPath,
          fit: BoxFit.contain,
          excludeFromSemantics: true,
        );
    }
  }
}
