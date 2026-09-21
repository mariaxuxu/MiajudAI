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
    this.keyboardType,
    this.prefixText,
    this.autofocus = false,
    this.maxLines = 1,
    this.minLines,
    this.isRequired = false,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;

  /// Teclado exibido (ex.: numerico decimal). Nao filtra nem valida o texto.
  final TextInputType? keyboardType;

  /// Texto fixo antes do valor digitado (ex.: `R$ `). E so apresentacao: nao
  /// entra no texto do [controller].
  final String? prefixText;

  /// Abre o campo com o foco (e o teclado) ja nele. Quem usa so liga quando o
  /// formulario tem um unico campo e o usuario vai digitar de imediato.
  final bool autofocus;

  /// Linhas maximas do campo (o padrao, 1, e o de um `TextField`). Com mais de
  /// uma, o campo comeca em [minLines] e cresce ate [maxLines].
  final int maxLines;
  final int? minLines;

  /// Marca o campo como obrigatorio: acrescenta um asterisco ao rotulo e
  /// "obrigatorio" ao que o leitor de tela anuncia. E so apresentacao: nada aqui
  /// valida ou bloqueia o envio.
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    final labelStyle = AppTypography.labelMedium.copyWith(
      color: AppSemanticColors.textSecondaryStrong,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // O rotulo visivel e lido junto com o campo (Semantics abaixo); sem
        // ExcludeSemantics ele seria anunciado duas vezes.
        ExcludeSemantics(
          child: isRequired
              ? Text.rich(
                  TextSpan(
                    text: label,
                    children: const [
                      TextSpan(
                        text: ' *',
                        style:
                            TextStyle(color: AppSemanticColors.onFeedbackError),
                      ),
                    ],
                  ),
                  style: labelStyle,
                )
              : Text(label, style: labelStyle),
        ),
        const SizedBox(height: AppSpacing.labelGap),
        Semantics(
          label: isRequired ? '$label, obrigatório' : label,
          child: TextField(
            controller: controller,
            autofocus: autofocus,
            maxLines: maxLines,
            minLines: minLines,
            keyboardType: keyboardType,
            style: AppTypography.bodyMedium.copyWith(
              color: AppSemanticColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: hint,
              // Sem rotulo flutuante, o Flutter so exibe o prefixo com o campo
              // focado ou preenchido; `always` o mantem visivel junto ao hint.
              floatingLabelBehavior:
                  prefixText != null ? FloatingLabelBehavior.always : null,
              prefixText: prefixText,
              prefixStyle: AppTypography.bodyMedium.copyWith(
                color: AppSemanticColors.textSecondaryStrong,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
