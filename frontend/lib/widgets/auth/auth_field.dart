import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/tokens/app_colors_semantic.dart';

/// Campo de formulario compartilhado para telas de autenticacao.
///
/// Rotulo acima, icone a esquerda e, quando [isPassword], alternancia de
/// visibilidade a direita. Bordas, preenchimento, altura (48) e raio (12)
/// vem do `InputDecorationTheme` de `AppTheme`, aplicado por
/// `AppScreenScaffold`; este widget so acrescenta o que e proprio do campo.
///
/// Usado exclusivamente por Login, Signup e pela recuperacao de senha.
class AuthField extends StatefulWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final IconData prefixIcon;
  final bool isPassword;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final void Function(String)? onChanged;
  final TextInputAction textInputAction;
  final FocusNode? focusNode;
  final VoidCallback? onEditingComplete;
  final bool autofocus;

  const AuthField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    required this.prefixIcon,
    this.isPassword = false,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.textInputAction = TextInputAction.next,
    this.focusNode,
    this.onEditingComplete,
    this.autofocus = false,
  });

  @override
  State<AuthField> createState() => _AuthFieldState();
}

class _AuthFieldState extends State<AuthField> {
  bool _obscure = true;
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // O rotulo visivel e lido junto com o campo (Semantics abaixo); sem
        // ExcludeSemantics ele seria anunciado duas vezes.
        ExcludeSemantics(
          child: Text(
            widget.label,
            style: AppTypography.labelMedium.copyWith(
              color: AppSemanticColors.textSecondaryStrong,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.labelGap),
        Semantics(
          label: widget.label,
          child: Focus(
            onFocusChange: (focused) => setState(() => _isFocused = focused),
            child: TextFormField(
              controller: widget.controller,
              obscureText: widget.isPassword && _obscure,
              keyboardType: widget.keyboardType,
              textInputAction: widget.textInputAction,
              focusNode: widget.focusNode,
              autofocus: widget.autofocus,
              onEditingComplete: widget.onEditingComplete,
              onChanged: widget.onChanged,
              validator: widget.validator,
              style: AppTypography.bodyMedium.copyWith(
                color: AppSemanticColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: widget.hint,
                prefixIcon: Icon(
                  widget.prefixIcon,
                  size: AppSizes.iconMd,
                  color: _isFocused
                      ? AppSemanticColors.actionPrimary
                      : AppSemanticColors.textSecondaryStrong,
                ),
                suffixIcon: widget.isPassword
                    ? IconButton(
                        tooltip: _obscure ? 'Mostrar senha' : 'Ocultar senha',
                        icon: Icon(
                          _obscure
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: AppSizes.iconMd,
                          color: AppSemanticColors.textSecondaryStrong,
                        ),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      )
                    : null,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
