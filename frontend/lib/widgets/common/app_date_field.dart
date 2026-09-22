import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/tokens/app_colors_semantic.dart';

/// Campo de data de formulario do Design System: rotulo acima e um campo
/// tocavel com icone de calendario e a data formatada (`dd/MM/yyyy`).
///
/// Nao abre seletor nenhum: quem usa recebe [onTap] e decide como escolher a
/// data (normalmente `showDatePicker`) e o que fazer com o resultado. Aqui
/// ficam so a apresentacao, o foco visivel e a semantica de botao.
class AppDateField extends StatefulWidget {
  const AppDateField({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final DateTime value;
  final VoidCallback onTap;

  @override
  State<AppDateField> createState() => _AppDateFieldState();
}

class _AppDateFieldState extends State<AppDateField> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final formatted = DateFormat('dd/MM/yyyy').format(widget.value);
    final radius = BorderRadius.circular(AppRadius.control);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
          button: true,
          label: '${widget.label}, $formatted',
          excludeSemantics: true,
          onTap: widget.onTap,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: radius,
            onFocusChange: (focused) => setState(() => _isFocused = focused),
            child: InputDecorator(
              isEmpty: false,
              isFocused: _isFocused,
              decoration: const InputDecoration(
                prefixIcon: Icon(
                  Icons.calendar_today_outlined,
                  size: AppSizes.iconMd,
                  color: AppSemanticColors.textSecondaryStrong,
                ),
              ),
              child: Text(
                formatted,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppSemanticColors.textPrimary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
