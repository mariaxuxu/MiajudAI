import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/tokens/app_colors_semantic.dart';
import '../../theme/tokens/app_primitives.dart';
import '../common/cropped_asset_image.dart';

/// Faixa de apresentacao dos agentes de IA na home.
///
/// E informativa: nao recebe toque nem navega. O acesso aos agentes continua
/// sendo pelo menu inferior.
class AgentsBanner extends StatelessWidget {
  const AgentsBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.defaultGap),
      decoration: BoxDecoration(
        color: AppSemanticColors.moduleAiSoft,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Row(
        children: [
          Expanded(child: _buildText()),
          const SizedBox(width: AppSpacing.labelGap),
          const SizedBox(
            width: 96,
            child: CroppedAssetImage(
              // Grupo de agentes: JPEG de fundo branco, dissolvido no lilas do
              // banner e recortado nas margens.
              asset: 'assets/images/todos_agents.jpg',
              assetSize: Size(1421, 1536),
              widthFactor: 0.82,
              heightFactor: 0.72,
              anchor: Alignment(-0.24, 0),
              blendInto: AppSemanticColors.moduleAiSoft,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const ExcludeSemantics(
              child: Icon(
                Icons.auto_awesome_rounded,
                size: AppSizes.iconMd,
                color: AppPrimitives.violet600,
              ),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                'Seus agentes de IA',
                style: AppTypography.labelMedium.copyWith(
                  color: AppSemanticColors.onModuleAi,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Converse com Luna, Otto ou Tina',
          style: AppTypography.titleMedium.copyWith(
            color: AppSemanticColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Dicas, respostas e um apoio real para o seu dia a dia.',
          style: AppTypography.bodySmall.copyWith(
            color: AppSemanticColors.textSecondaryStrong,
          ),
        ),
      ],
    );
  }
}
