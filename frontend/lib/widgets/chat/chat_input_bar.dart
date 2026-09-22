import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/tokens/app_colors_semantic.dart';
import '../../theme/tokens/app_primitives.dart';

/// Campo de mensagem do chat: pilula com o campo de texto e o botao de envio.
///
/// Enquanto [isLoading], campo e botao ficam desabilitados. O widget nao
/// valida nem envia nada: chama [onSend] (botao ou "enviar" do teclado) e
/// quem usa decide o que fazer com o texto do [controller].
class ChatInputBar extends StatelessWidget {
  const ChatInputBar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.isLoading,
    required this.onSend,
    required this.hintText,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isLoading;
  final VoidCallback onSend;
  final String hintText;

  static const double _sendSize = 52;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.labelGap),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppSemanticColors.surface,
          borderRadius: BorderRadius.circular(32),
          boxShadow: AppPrimitives.shadowMd,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.labelGap),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(child: _buildField()),
              const SizedBox(width: AppSpacing.labelGap),
              IconButton.filled(
                onPressed: isLoading ? null : onSend,
                tooltip: 'Enviar mensagem',
                icon: const Icon(Icons.send_rounded, size: 22),
                style: IconButton.styleFrom(
                  fixedSize: const Size(_sendSize, _sendSize),
                  backgroundColor: AppSemanticColors.actionPrimary,
                  foregroundColor: AppSemanticColors.onAction,
                  disabledBackgroundColor: AppSemanticColors.actionDisabled,
                  disabledForegroundColor: AppSemanticColors.onActionDisabled,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField() {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      enabled: !isLoading,
      maxLines: 4,
      minLines: 1,
      textInputAction: TextInputAction.send,
      onSubmitted: (_) => onSend(),
      style: AppTypography.bodyMedium.copyWith(
        color: AppSemanticColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppTypography.bodyMedium.copyWith(
          color: AppSemanticColors.textSecondary,
        ),
        filled: true,
        fillColor: AppSemanticColors.background,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenGutter - 4,
          vertical: 14,
        ),
        border: _border(AppSemanticColors.border),
        enabledBorder: _border(AppSemanticColors.border),
        disabledBorder: _border(AppSemanticColors.border),
        // Foco sempre visivel (WCAG 2.2 AA, criterio 2.4.11).
        focusedBorder: _border(AppSemanticColors.focusRing, width: 2),
      ),
    );
  }

  static OutlineInputBorder _border(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(_sendSize / 2),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
