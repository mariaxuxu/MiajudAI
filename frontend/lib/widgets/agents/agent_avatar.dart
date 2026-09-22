import 'package:flutter/material.dart';

import '../../theme/tokens/app_colors_semantic.dart';
import '../common/cropped_asset_image.dart';

/// Avatar circular de um agente (cabecalho e mensagens do chat).
///
/// E decorativo: o nome do agente sempre aparece em texto ao lado, entao a
/// imagem fica fora da arvore de semantica.
///
/// A Luna e recortada no rosto. Os agentes sem recorte medido mostram a
/// ilustracao inteira, contida e com respiro, como a navegacao inferior faz.
class AgentAvatar extends StatelessWidget {
  const AgentAvatar({super.key, required this.agent, this.size = 40});

  final AppAgent agent;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: agent.surface,
          shape: BoxShape.circle,
          border: Border.all(color: AppSemanticColors.border),
        ),
        child: ClipOval(child: _art()),
      ),
    );
  }

  Widget _art() {
    switch (agent) {
      case AppAgent.luna:
        // luna.png tem 2048x2048; a cabeca fica em x 0,369-0,600 e
        // y 0,074-0,299. O recorte de 34% deixa uma folga de orelhas e pescoco.
        return CroppedAssetImage(
          asset: agent.assetPath,
          assetSize: const Size(2048, 2048),
          widthFactor: 0.34,
          heightFactor: 0.34,
          anchor: const Alignment(-0.045, -0.879),
        );
      case AppAgent.otto:
      case AppAgent.tina:
        return Padding(
          padding: EdgeInsets.all(size * 0.15),
          child: Image.asset(
            agent.assetPath,
            fit: BoxFit.contain,
            excludeFromSemantics: true,
          ),
        );
    }
  }
}
