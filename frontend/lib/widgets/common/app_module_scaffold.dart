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
/// Duas capacidades opcionais, para telas com abas:
///  - [topBar]: faixa FIXA logo abaixo do [header] (ex.: abas e seletor de mes);
///  - `scrollable: false`: o [child] ocupa o espaco restante SEM rolagem
///    propria. Cada pagina do [child] (ex.: as do `TabBarView`) rola sozinha
///    envolvendo o seu conteudo em [ModuleScrollBody].
class AppModuleScaffold extends StatelessWidget {
  const AppModuleScaffold({
    super.key,
    required this.header,
    required this.child,
    this.topBar,
    this.scrollable = true,
    this.floatingActionButton,
  });

  /// Barra do topo, fixa (normalmente um `ModuleScreenHeader`).
  final Widget header;

  /// Conteudo da tela; rola quando nao cabe (a menos que [scrollable] seja
  /// falso).
  final Widget child;

  /// Faixa fixa entre o [header] e o [child]; recebe o gutter lateral.
  final Widget? topBar;

  /// Quando falso, [child] nao ganha `SingleChildScrollView`: quem o fornece
  /// cuida da rolagem (ver [ModuleScrollBody]).
  final bool scrollable;

  final Widget? floatingActionButton;

  /// Espaco extra no fim da rolagem: FAB (56) mais respiro.
  static const double fabClearance = 96;

  /// Em telas estreitas o gutter cede antes do conteudo, para evitar overflow
  /// sem quebrar a composicao (mesma regra de `AppScreenScaffold`).
  static double gutterFor(double width) => width < AppBreakpoints.compact
      ? AppSpacing.screenGutter * 0.66
      : AppSpacing.screenGutter;

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
                    final gutter = gutterFor(constraints.maxWidth);
                    final topBar = this.topBar;

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
                            if (topBar != null)
                              Padding(
                                padding: EdgeInsets.fromLTRB(
                                  gutter,
                                  AppSpacing.itemGap,
                                  gutter,
                                  0,
                                ),
                                child: topBar,
                              ),
                            Expanded(
                              child: scrollable
                                  ? SingleChildScrollView(
                                      padding: EdgeInsets.fromLTRB(
                                        gutter,
                                        AppSpacing.defaultGap,
                                        gutter,
                                        floatingActionButton != null
                                            ? fabClearance
                                            : AppSpacing.defaultGap,
                                      ),
                                      child: child,
                                    )
                                  : child,
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

/// Corpo rolavel de UMA pagina de uma tela `AppModuleScaffold(scrollable:
/// false)`: aplica o mesmo gutter, o mesmo respiro no topo e o mesmo espaco
/// para o FAB que o corpo padrao do scaffold.
class ModuleScrollBody extends StatelessWidget {
  const ModuleScrollBody({super.key, required this.child, this.hasFab = true});

  final Widget child;

  /// Reserva espaco no fim para o FAB nao cobrir o ultimo item.
  final bool hasFab;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final gutter = AppModuleScaffold.gutterFor(constraints.maxWidth);

        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            gutter,
            AppSpacing.defaultGap,
            gutter,
            hasFab ? AppModuleScaffold.fabClearance : AppSpacing.defaultGap,
          ),
          child: child,
        );
      },
    );
  }
}
