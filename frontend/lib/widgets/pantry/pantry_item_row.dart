import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/tokens/app_colors_semantic.dart';
import '../../theme/tokens/app_primitives.dart';
import 'quantity_stepper.dart';

/// Linha da despensa: emoji, nome e o stepper −/+ do que o usuario POSSUI.
///
/// Cada toque chama [onIncrement]/[onDecrement] com o proximo valor, e quem
/// usa decide o que fazer (na despensa, escreve na hora via PATCH).
class PantryItemRow extends StatelessWidget {
  const PantryItemRow({
    super.key,
    required this.emoji,
    required this.name,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
  });

  final String emoji;
  final String name;
  final int quantity;
  final VoidCallback onIncrement;

  /// Nulo desabilita o "−" (nunca chega a 0 sem remover; ver a tela).
  final VoidCallback? onDecrement;

  @override
  Widget build(BuildContext context) {
    return _RowShell(
      emoji: emoji,
      title: name,
      trailing: QuantityStepper(
        value: quantity,
        onIncrement: onIncrement,
        onDecrement: onDecrement,
        // Piso 0: com quantidade 1 o "−" continua habilitado e o toque manda 0,
        // que e o que remove o item da despensa.
        minValue: 0,
        semanticsLabel: name,
      ),
    );
  }
}

/// Linha do catalogo: emoji, nome, quanto o usuario JA tem, e o stepper −/+
/// do carrinho (quantos esta comprando NESTA ida).
class CatalogItemRow extends StatelessWidget {
  const CatalogItemRow({
    super.key,
    required this.emoji,
    required this.name,
    required this.ownedQuantity,
    required this.cartQuantity,
    required this.onIncrement,
    required this.onDecrement,
  });

  final String emoji;
  final String name;
  final int ownedQuantity;
  final int cartQuantity;
  final VoidCallback onIncrement;

  /// Nulo desabilita o "−" (o carrinho tem piso 0).
  final VoidCallback? onDecrement;

  @override
  Widget build(BuildContext context) {
    return _RowShell(
      emoji: emoji,
      title: name,
      subtitle: 'você tem $ownedQuantity',
      trailing: QuantityStepper(
        value: cartQuantity,
        onIncrement: onIncrement,
        onDecrement: onDecrement,
        minValue: 0,
        semanticsLabel: name,
      ),
    );
  }
}

/// Casca comum das duas linhas: card, bloco tonal do emoji e coluna de texto
/// a esquerda, com o stepper a direita.
class _RowShell extends StatelessWidget {
  const _RowShell({
    required this.emoji,
    required this.title,
    this.subtitle,
    required this.trailing,
  });

  final String emoji;
  final String title;
  final String? subtitle;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.itemGap),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.itemGap,
        AppSpacing.itemGap,
        AppSpacing.labelGap,
        AppSpacing.itemGap,
      ),
      decoration: BoxDecoration(
        color: AppSemanticColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppPrimitives.shadowSm,
      ),
      child: Row(
        children: [
          ExcludeSemantics(
            child: Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppSemanticColors.surfaceSubtle,
                borderRadius: BorderRadius.circular(AppRadius.control),
              ),
              child: Text(emoji, style: const TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: AppSpacing.itemGap),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.titleMedium.copyWith(
                    color: AppSemanticColors.textPrimary,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppSemanticColors.textSecondaryStrong,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.labelGap),
          trailing,
        ],
      ),
    );
  }
}
