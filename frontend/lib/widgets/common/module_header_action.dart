import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import '../../theme/tokens/app_colors_semantic.dart';

/// Acao em icone do cabecalho de uma tela de modulo (`ModuleScreenHeader`),
/// num bloco tonal azul de 48dp.
///
/// So apresenta: quem usa passa o [onPressed] (o destino) e o [tooltip], que
/// tambem e o rotulo lido por leitores de tela.
class ModuleHeaderAction extends StatelessWidget {
  const ModuleHeaderAction({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon),
      style: IconButton.styleFrom(
        fixedSize: const Size.square(AppSpacing.minTouchTarget),
        // Tom 100 (nao 50): sobre as curvas de fundo da tela o bloco 50 some.
        backgroundColor: AppTone.blue.surface,
        foregroundColor: AppTone.blue.foreground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
        ),
      ),
    );
  }
}
