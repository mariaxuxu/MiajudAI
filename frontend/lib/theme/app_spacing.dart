import 'tokens/app_primitives.dart';

/// Espacamentos semanticos, derivados do grid base de 4px.
abstract final class AppSpacing {
  /// Padding horizontal padrao das telas (DS: 24px).
  static const double screenGutter = AppPrimitives.space6;

  /// Espacamento padrao entre elementos relacionados (DS: 16px).
  static const double defaultGap = AppPrimitives.space4;

  /// Respiro entre secoes distintas de uma tela.
  static const double sectionGap = AppPrimitives.space8;

  /// Padding interno de cards.
  static const double cardPadding = AppPrimitives.space4;

  /// Espaco entre itens de uma lista/grade.
  static const double itemGap = AppPrimitives.space3;

  /// Alvo minimo de toque (WCAG 2.2 AA / Material).
  static const double minTouchTarget = 48;
}

/// Raios semanticos.
abstract final class AppRadius {
  static const double card = AppPrimitives.radius16;
  static const double control = AppPrimitives.radius12; // botao / input
  static const double chip = AppPrimitives.radius8;
  static const double sheet = AppPrimitives.radius24;
  static const double full = AppPrimitives.radiusFull;
}

/// Alturas recorrentes.
abstract final class AppSizes {
  /// Altura de botao e input (DS: 48px).
  static const double control = 48;
  static const double iconSm = 16;
  static const double iconMd = 20;
  static const double iconLg = 24;
}
