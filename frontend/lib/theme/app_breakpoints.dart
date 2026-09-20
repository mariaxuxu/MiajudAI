import 'package:flutter/widgets.dart';

/// Breakpoints do Design System.
///
/// Viewport mobile de referencia: 390 x 844.
abstract final class AppBreakpoints {
  /// Abaixo disto o layout precisa comprimir para nao estourar.
  static const double compact = 390;

  /// Tablets e janelas estreitas de desktop.
  static const double medium = 600;

  /// Desktop.
  static const double expanded = 1024;

  /// Largura maxima do conteudo — evita linhas longas demais em telas largas.
  static const double maxContentWidth = 480;

  static bool isBelowCompact(BuildContext context) =>
      MediaQuery.sizeOf(context).width < compact;

  static bool isMediumUp(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= medium;
}
