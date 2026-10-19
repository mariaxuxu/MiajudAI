import 'package:flutter/material.dart';

import '../../theme/app_typography.dart';
import '../../theme/tokens/app_colors_semantic.dart';
import '../common/app_primary_button.dart';

/// Barra fixa de confirmacao do carrinho: resumo a esquerda, botao a direita.
///
/// Sem itens no carrinho o botao fica desabilitado (nao ha o que confirmar);
/// quem usa decide o que fazer ao confirmar.
class CartConfirmBar extends StatelessWidget {
  const CartConfirmBar({
    super.key,
    required this.itemCount,
    required this.packCount,
    required this.onConfirm,
    this.isLoading = false,
  });

  /// Quantos itens distintos estao no carrinho.
  final int itemCount;

  /// Soma dos pacotes do carrinho.
  final int packCount;

  final VoidCallback onConfirm;
  final bool isLoading;

  static String summaryLabel(int itemCount, int packCount) {
    final items = itemCount == 1 ? '1 item' : '$itemCount itens';
    final packs = packCount == 1 ? '1 pacote' : '$packCount pacotes';
    return '$items · $packs';
  }

  @override
  Widget build(BuildContext context) {
    final hasItems = itemCount > 0;

    return Row(
      children: [
        Expanded(
          child: Text(
            hasItems ? summaryLabel(itemCount, packCount) : 'Carrinho vazio',
            style: AppTypography.bodyMedium.copyWith(
              color: hasItems
                  ? AppSemanticColors.textPrimary
                  : AppSemanticColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: 12),
        // AppPrimaryButton pede largura infinita por padrao (Size.fromHeight);
        // dentro de um Row isso estoura, entao o tamanho fica intrinseco.
        IntrinsicWidth(
          child: AppPrimaryButton(
            label: 'Confirmar',
            onPressed: hasItems ? onConfirm : null,
            isLoading: isLoading,
            trailingIcon: Icons.check_rounded,
          ),
        ),
      ],
    );
  }
}
