import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/tokens/app_colors_semantic.dart';

/// Campo de texto de formulario do Design System: rotulo acima e campo abaixo.
///
/// Borda, preenchimento, altura (48) e raio (12) vem do `InputDecorationTheme`
/// de `AppTheme`. Este widget e o irmao de `AuthField` para formularios que
/// nao sao de autenticacao (sem icone, sem alternancia de senha).
///
/// Continua sendo um `TextField` comum: quem usa segue dono do controller, e
/// nada aqui valida ou transforma o texto digitado.
class AppFormField extends StatelessWidget {
  const AppFormField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // O rotulo visivel e lido junto com o campo (Semantics abaixo); sem
        // ExcludeSemantics ele seria anunciado duas vezes.
        ExcludeSemantics(
          child: Text(
            label,
            style: AppTypography.labelMedium.copyWith(
              color: AppSemanticColors.textSecondaryStrong,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.labelGap),
        Semantics(
          label: label,
          child: TextField(
            controller: controller,
            style: AppTypography.bodyMedium.copyWith(
              color: AppSemanticColors.textPrimary,
            ),
            decoration: InputDecoration(hintText: hint),
          ),
        ),
      ],
    );
  }
}
