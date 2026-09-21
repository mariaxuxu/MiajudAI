import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_breakpoints.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/app_colors_semantic.dart';
import 'app_backdrop.dart';

/// Casca visual das telas de modulo redesenhadas (financas, calendario,
/// diario).
///
/// Diferente de `AppScreenScaffold` (centrada e toda rolavel, pensada para
/// login e home), aqui o [header] fica fixo no topo e so o [child] rola. Tambem
/// acomoda um [floatingActionButton] e reserva espaco de rolagem para que o
/// conteudo nao termine escondido atras dele.
///
/// Aplica o [AppTheme] LOCALMENTE, como as demais telas redesenhadas; o tema
/// global do `MaterialApp` permanece intacto.
///
/// Nasce so com o que a primeira tela exige. Abas, seletor de mes e corpo sem
/// rolagem entram quando uma fase posterior realmente precisar.
class AppModuleScaffold extends StatelessWidget {
  const AppModuleScaffold({
    super.key,
    required this.header,
    required this.child,
    this.floatingActionButton,
  });

  /// Barra do topo, fixa (normalmente um `ModuleScreenHeader`).
  final Widget header;

  /// Conteudo da tela; rola quando nao cabe.
  final Widget child;

  final Widget? floatingActionButton;

  /// Espaco extra no fim da rolagem: FAB (56) mais respiro.
  static const double _fabClearance = 96;

  static const SystemUiOverlayStyle _overlayStyle = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarBrightness: Brightness.light,
    statusBarIconBrightness: Brightness.dark,
  );

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.light,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: _overlayStyle,
        child: Scaffold(
          backgroundColor: AppSemanticColors.background,
          floatingActionButton: floatingActionButton,
          body: Stack(
            children: [
              const Positioned.fill(child: AppBackdrop()),
              SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Em telas estreitas o gutter cede antes do conteudo,
                    // como em AppScreenScaffold.
                    final gutter = constraints.maxWidth < AppBreakpoints.compact
                        ? AppSpacing.screenGutter * 0.66
                        : AppSpacing.screenGutter;

                    return Align(
                      alignment: Alignment.topCenter,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: AppBreakpoints.maxContentWidth,
                        ),
                        child: Column(
                          children: [
                            // O glifo de voltar (IconButton de 48dp) tem folga
                            // interna; o recuo a esquerda a compensa para o
                            // icone alinhar com o gutter do conteudo.
                            Padding(
                              padding: EdgeInsets.fromLTRB(
                                gutter - AppSpacing.labelGap,
                                AppSpacing.labelGap,
                                gutter,
                                0,
                              ),
                              child: header,
                            ),
                            Expanded(
                              child: SingleChildScrollView(
                                padding: EdgeInsets.fromLTRB(
                                  gutter,
                                  AppSpacing.defaultGap,
                                  gutter,
                                  floatingActionButton != null
                                      ? _fabClearance
                                      : AppSpacing.defaultGap,
                                ),
                                child: child,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
