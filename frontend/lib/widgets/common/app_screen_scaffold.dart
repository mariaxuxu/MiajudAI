import 'dart:math' as math;

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
///
/// Posicionamento vertical:
///  - sem [footer], o [child] fica em [contentAlignment] (centro por padrao)
///    quando sobra espaco;
///  - com [footer], o [child] fica no topo e o [footer] e ancorado na base da
///    viewport quando sobra espaco. Quando nao sobra, os dois rolam juntos.
class AppScreenScaffold extends StatelessWidget {
  const AppScreenScaffold({
    super.key,
    required this.child,
    this.footer,
    this.contentAlignment = Alignment.center,
    this.showBackdrop = true,
    this.horizontalPadding = AppSpacing.screenGutter,
    this.topPadding = 12,
    this.bottomPadding = AppSpacing.defaultGap,
  });

  final Widget child;

  /// Conteudo ancorado na base (ex.: ilustracao). Opcional.
  final Widget? footer;

  /// Onde o [child] fica quando sobra altura e nao ha [footer].
  final Alignment contentAlignment;

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

                  final minHeight = math.max(
                    0.0,
                    constraints.maxHeight - topPadding - bottomPadding,
                  );

                  return SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      gutter,
                      topPadding,
                      gutter,
                      bottomPadding,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: minHeight),
                      child: Align(
                        alignment: contentAlignment,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: AppBreakpoints.maxContentWidth,
                          ),
                          child: _withFooter(minHeight),
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

  /// Sem [footer] devolve o [child] intacto.
  ///
  /// Com [footer], empurra child e footer para as pontas de uma coluna que
  /// ocupa no minimo a altura visivel. Nao usa `Expanded`/`IntrinsicHeight`
  /// de proposito: dimensoes intrinsecas divergem do layout real quando ha
  /// texto quebrando dentro de `Row`, o que gerava overflow.
  Widget _withFooter(double minHeight) {
    final footer = this.footer;
    if (footer == null) return child;

    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: minHeight),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [child, footer],
      ),
    );
  }
}
