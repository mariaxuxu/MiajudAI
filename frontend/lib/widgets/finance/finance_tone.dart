import 'package:flutter/widgets.dart';

import '../../theme/tokens/app_colors_semantic.dart';

/// Identidade de cor de um dominio financeiro, compartilhada pelos cards da
/// area de financas (resumo, dica, item de lista, estado vazio).
///
/// A cor identifica o dominio, mas o significado nunca depende so dela: todo
/// card traz rotulo e texto proprios.
///
/// `income` (receitas, verde), `expense` (despesas, vermelho), `installment`
/// (parcelas, azul), `fixedCost` (gastos fixos, ambar) e `neutral` (totais sem
/// dominio proprio, cinza).
enum FinanceTone {
  income(
    background: AppSemanticColors.feedbackSuccessSubtle,
    // emerald500 a 20%: contorno suave sobre o fundo tonal.
    border: Color(0x3310B981),
    tone: AppTone.green,
    value: AppSemanticColors.onFeedbackSuccess,
    accent: AppSemanticColors.feedbackSuccess,
  ),
  expense(
    background: AppSemanticColors.feedbackErrorSubtle,
    // red500 a 20%.
    border: Color(0x33EF4444),
    tone: AppTone.red,
    value: AppSemanticColors.onFeedbackError,
    accent: AppSemanticColors.feedbackError,
  ),
  installment(
    background: AppSemanticColors.actionPrimarySubtle,
    // blue600 a 20%.
    border: Color(0x332563EB),
    tone: AppTone.blue,
    value: AppSemanticColors.actionPrimaryHover,
    accent: AppSemanticColors.actionPrimary,
  ),
  fixedCost(
    background: AppSemanticColors.feedbackWarningSubtle,
    // amber500 a 20%.
    border: Color(0x33F59E0B),
    tone: AppTone.amber,
    value: AppSemanticColors.onFeedbackWarning,
    accent: AppSemanticColors.feedbackWarning,
  ),
  neutral(
    background: AppSemanticColors.surfaceSubtle,
    border: AppSemanticColors.border,
    tone: AppTone.slate,
    value: AppSemanticColors.textPrimary,
    accent: AppSemanticColors.textSecondaryStrong,
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
