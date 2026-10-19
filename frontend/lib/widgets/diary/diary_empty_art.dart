import 'package:flutter/material.dart';

import '../../theme/tokens/app_colors_semantic.dart';

/// Ilustracao do dia sem entradas: um bloco de notas sobre um circulo suave,
/// com um selo azul de "+".
///
/// Ornamental: quem a usa (`EmptyStateCard`) ja a tira da semantica.
class DiaryEmptyArt extends StatelessWidget {
  const DiaryEmptyArt({super.key});

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
            Icons.edit_note_rounded,
            size: 64,
            color: AppSemanticColors.textTertiary,
          ),
          Positioned(
            right: 20,
            bottom: 22,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppSemanticColors.actionPrimary,
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
