import 'package:flutter/material.dart';

import '../../theme/tokens/app_colors_semantic.dart';
import 'finance_tone.dart';

/// Ilustracao de estado vazio das listas financeiras: um recibo sobre um
/// circulo suave, com um selo "+" na cor do dominio.
///
/// Ornamental: quem a usa (`EmptyStateCard`) ja a tira da semantica.
class FinanceEmptyArt extends StatelessWidget {
  const FinanceEmptyArt({super.key, required this.tone});

  final FinanceTone tone;

  static const double _size = 120;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _size,
      height: _size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: _size,
            height: _size,
            decoration: const BoxDecoration(
              color: AppSemanticColors.actionPrimarySubtle,
              shape: BoxShape.circle,
            ),
          ),
          const Icon(
            Icons.receipt_long_outlined,
            size: 60,
            color: AppSemanticColors.textTertiary,
          ),
          Positioned(
            right: 20,
            bottom: 22,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: tone.tone.foreground,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppSemanticColors.surface,
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.add_rounded,
                size: 20,
                color: AppSemanticColors.onAction,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
