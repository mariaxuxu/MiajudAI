import 'package:flutter/widgets.dart';

import '../../theme/tokens/app_colors_semantic.dart';

/// Identidade de cor de um dominio financeiro, compartilhada pelos cards da
/// area de financas (resumo, dica, item de lista, estado vazio).
///
/// A cor identifica o dominio, mas o significado nunca depende so dela: todo
/// card traz rotulo e texto proprios.
///
/// Nasce com `income` (receitas, verde). Despesas (vermelho), parcelas e
/// gastos fixos (ambar) entram quando as suas fases precisarem.
enum FinanceTone {
  income(
    background: AppSemanticColors.feedbackSuccessSubtle,
    // emerald500 a 20%: contorno suave sobre o fundo tonal.
    border: Color(0x3310B981),
    tone: AppTone.green,
    value: AppSemanticColors.onFeedbackSuccess,
    accent: AppSemanticColors.feedbackSuccess,
  );

  const FinanceTone({
    required this.background,
    required this.border,
    required this.tone,
    required this.value,
    required this.accent,
  });

  /// Fundo de cards tonais (resumo do mes, dica).
  final Color background;

  /// Contorno de cards tonais.
  final Color border;

  /// Par bloco-do-icone / cor-do-icone.
  final AppTone tone;

  /// Cor de valores monetarios e destaques em texto. Passa AA (>= 4.5:1) sobre
  /// [background] e sobre a superficie branca.
  final Color value;

  /// Cor da barra do titulo de secao.
  final Color accent;
}
