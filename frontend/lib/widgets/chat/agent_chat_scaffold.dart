import 'package:flutter/material.dart';

import '../../theme/app_breakpoints.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/app_colors_semantic.dart';
import '../common/app_backdrop.dart';

/// Estrutura visual compartilhada pelas telas de chat dos agentes
/// (Luna hoje; pensada para Otto e Tina reusarem a mesma estrutura).
///
/// Diferente de `AppScreenScaffold`, aqui nada rola por fora: cabecalho e
/// rodape ficam fixos e so o [body] ocupa (e rola dentro de) o espaco que
/// sobra. Isso mantem o campo de mensagem visivel com o teclado aberto.
///
/// Aplica o [AppTheme] LOCALMENTE, como as demais telas redesenhadas; o tema
/// global do `MaterialApp` continua intacto.
class AgentChatScaffold extends StatelessWidget {
  const AgentChatScaffold({
    super.key,
    required this.header,
    required this.body,
    required this.footer,
  });

  /// Barra do topo (voltar, agente, acoes).
  final Widget header;

  /// Conteudo principal: estado inicial ou lista de mensagens.
  final Widget body;

  /// Base da tela: aviso de erro e campo de mensagem.
  final Widget footer;

  /// Margem lateral do conteudo. Cede em telas mais estreitas que a
  /// referencia (390), como as demais telas redesenhadas.
  static double gutterOf(BuildContext context) =>
      AppBreakpoints.isBelowCompact(context)
          ? AppSpacing.screenGutter * 0.66
          : AppSpacing.screenGutter;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.light,
      child: Scaffold(
        backgroundColor: AppSemanticColors.background,
        body: Stack(
          children: [
            const Positioned.fill(child: AppBackdrop()),
            SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppBreakpoints.maxContentWidth,
                  ),
                  child: Column(
                    children: [
                      header,
                      Expanded(child: body),
                      footer,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
