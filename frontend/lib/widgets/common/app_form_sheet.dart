import 'package:flutter/material.dart';

import '../../theme/app_breakpoints.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_typography.dart';
import '../../theme/tokens/app_colors_semantic.dart';

/// Bottom sheet de formulario do Design System.
///
/// Uma sheet e uma ROTA nova: ela nao herda o `Theme` que a tela aplicou
/// localmente, entao [show] reaplica o [AppTheme] dentro dela. Cuida so da
/// casca visual (grab handle, titulo, rolagem e afastamento do teclado); o
/// conteudo, a validacao e o envio continuam sendo da tela.
///
/// Mantem `isScrollControlled: true`, como os sheets legados, para o teclado
/// nao cobrir os campos.
abstract final class AppFormSheet {
  /// [builder] recebe o contexto da rota da sheet (o mesmo que os formularios
  /// legados usam para `Navigator.pop` e para exibir feedback).
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required Widget Function(BuildContext sheetContext) builder,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppSemanticColors.surface,
      constraints: const BoxConstraints(
        maxWidth: AppBreakpoints.maxContentWidth,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.sheet),
        ),
      ),
      builder: (sheetContext) => Theme(
        data: AppTheme.light,
        child: _AppFormSheetBody(
          title: title,
          child: builder(sheetContext),
        ),
      ),
    );
  }
}

class _AppFormSheetBody extends StatelessWidget {
  const _AppFormSheetBody({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenGutter,
        AppSpacing.itemGap,
        AppSpacing.screenGutter,
        MediaQuery.viewInsetsOf(context).bottom + AppSpacing.screenGutter,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: ExcludeSemantics(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppSemanticColors.borderStrong,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.defaultGap + 4),
          Semantics(
            header: true,
            child: Text(
              title,
              style: AppTypography.headlineMedium.copyWith(
                color: AppSemanticColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.defaultGap + 4),
          child,
        ],
      ),
    );
  }
}
