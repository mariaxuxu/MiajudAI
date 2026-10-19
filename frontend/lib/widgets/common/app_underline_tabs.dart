import 'package:flutter/material.dart';

import '../../theme/app_typography.dart';
import '../../theme/tokens/app_colors_semantic.dart';

/// Abas com indicador sublinhado, ligadas a um [TabController] que quem usa ja
/// possui.
///
/// E o irmao de `AppSegmentedTabs` (pilulas) para telas cujo desenho usa abas
/// de duas ou tres opcoes que dividem a largura. Continua sendo um `TabBar`
/// comum: o estado selecionado, o toque, o deslize do `TabBarView` e a
/// semantica de aba ("aba N de M, selecionada") sao do proprio Flutter. Aqui
/// so ficam as cores e o tipo do Design System.
///
/// Quem usa continua dono do controller e do `TabBarView`.
class AppUnderlineTabs extends StatelessWidget {
  const AppUnderlineTabs({
    super.key,
    required this.controller,
    required this.labels,
  });

  final TabController controller;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: controller,
      tabs: [for (final label in labels) Tab(text: label)],
      labelStyle: AppTypography.labelLarge,
      unselectedLabelStyle: AppTypography.labelLarge,
      labelColor: AppSemanticColors.actionPrimary,
      unselectedLabelColor: AppSemanticColors.textSecondaryStrong,
      indicatorColor: AppSemanticColors.actionPrimary,
      indicatorWeight: 3,
      indicatorSize: TabBarIndicatorSize.label,
      dividerColor: AppSemanticColors.border,
      dividerHeight: 1,
    );
  }
}
