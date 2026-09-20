import 'package:flutter/material.dart';

import '../../theme/app_breakpoints.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/app_colors_semantic.dart';
import 'app_backdrop.dart';

/// Casca visual das telas redesenhadas.
///
/// Aplica o [AppTheme] LOCALMENTE, por subarvore. O tema global do
/// `MaterialApp` permanece intocado, de modo que as telas ainda nao
/// redesenhadas continuam exatamente como estao.
///
/// Cuida tambem de: `SafeArea`, gutter horizontal de 24px, largura maxima de
/// conteudo em telas largas e rolagem quando o conteudo nao cabe na viewport.
class AppScreenScaffold extends StatelessWidget {
  const AppScreenScaffold({
    super.key,
    required this.child,
    this.showBackdrop = true,
    this.horizontalPadding = AppSpacing.screenGutter,
    this.topPadding = 12,
    this.bottomPadding = AppSpacing.defaultGap,
  });

  final Widget child;
  final bool showBackdrop;
  final double horizontalPadding;
  final double topPadding;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.light,
      child: Scaffold(
        backgroundColor: AppSemanticColors.background,
        body: Stack(
          children: [
            if (showBackdrop) const Positioned.fill(child: AppBackdrop()),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Em telas estreitas o gutter cede antes do conteudo, para
                  // evitar overflow sem quebrar a composicao.
                  final gutter = constraints.maxWidth < AppBreakpoints.compact
                      ? horizontalPadding * 0.66
                      : horizontalPadding;

                  return SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      gutter,
                      topPadding,
                      gutter,
                      bottomPadding,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight:
                            constraints.maxHeight - topPadding - bottomPadding,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: AppBreakpoints.maxContentWidth,
                          ),
                          child: child,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
