import 'package:flutter/material.dart';

import '../../theme/tokens/app_colors_semantic.dart';
import 'finance_tone.dart';

/// Ilustracao de estado vazio das listas financeiras: um glifo sobre um
/// circulo suave, com um selo na cor do dominio.
///
/// Por padrao e um recibo com selo "+" (receitas e despesas); [icon] e
/// [sealIcon] trocam os glifos para outros vazios (ex.: relogio para parcelas,
/// cifrao para gastos fixos) sem mudar a composicao.
///
/// Ornamental: quem a usa (`EmptyStateCard`) ja a tira da semantica.
class FinanceEmptyArt extends StatelessWidget {
  const FinanceEmptyArt({
    super.key,
    required this.tone,
    this.icon = Icons.receipt_long_outlined,
    this.sealIcon = Icons.add_rounded,
  });

  final FinanceTone tone;

  /// Glifo grande, no centro do circulo.
  final IconData icon;

  /// Glifo dentro do selo colorido.
  final IconData sealIcon;

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
          Icon(
            icon,
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
              child: Icon(
                sealIcon,
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
