import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import '../../theme/tokens/app_colors_semantic.dart';

/// Botao de acao primaria do Design System (48px, radius 12).
///
/// Envolve o [FilledButton] estilizado por `AppTheme` e acrescenta apenas o
/// que se repete nas telas: seta opcional a direita e estado de carregamento.
///
/// Durante [isLoading] o botao fica inerte (sem toque, sem envio duplo) mas
/// NAO desbota para o cinza de "desabilitado": mantem a cor de acao com um
/// indicador de progresso, para o usuario entender que algo esta em curso.
class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.trailingIcon,
  });

  final String label;

  /// Nulo desabilita o botao (visual cinza de desabilitado).
  final VoidCallback? onPressed;

  final bool isLoading;

  /// Icone a direita do rotulo (ex.: seta). O rotulo continua centralizado.
  final IconData? trailingIcon;

  static const ButtonStyle _loadingStyle = ButtonStyle(
    backgroundColor: WidgetStatePropertyAll(AppSemanticColors.actionPrimary),
    foregroundColor: WidgetStatePropertyAll(AppSemanticColors.onAction),
  );

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: isLoading ? null : onPressed,
      style: isLoading ? _loadingStyle : null,
      child: isLoading ? _buildSpinner() : _buildLabel(),
    );
  }

  Widget _buildSpinner() {
    return const SizedBox(
      width: AppSizes.iconMd,
      height: AppSizes.iconMd,
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        color: AppSemanticColors.onAction,
        semanticsLabel: 'Carregando',
      ),
    );
  }

  Widget _buildLabel() {
    final icon = trailingIcon;
    if (icon == null) return Text(label);

    return Row(
      children: [
        // Contrapeso do icone, para o rotulo ficar opticamente centrado.
        const SizedBox(width: AppSizes.iconMd),
        Expanded(child: Text(label, textAlign: TextAlign.center)),
        Icon(icon, size: AppSizes.iconMd),
      ],
    );
  }
}
