import 'package:flutter/material.dart';

/// Utility class para adaptações responsivas de UI
class ResponsiveUtil {
  /// Padding responsivo baseado na largura da tela
  static double getResponsivePadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) return 12.0;      // Dispositivos pequenos (SE, etc)
    if (width < 600) return 16.0;      // Phones normais
    if (width < 900) return 24.0;      // Tablets
    return 32.0;                       // Desktops grandes
  }

  /// Largura máxima para containers principais
  static double getMaxWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return width - 32;  // Deixar 16px de margem em cada lado
    if (width < 900) return 800;          // Limitar em tablets
    return 1200;                          // Limitar em desktops
  }

  /// Tamanho de ícones em containers (squared icons)
  static double getIconContainerSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) return 44.0;      // Pequeno
    if (width < 600) return 56.0;      // Normal
    if (width < 900) return 64.0;      // Grande
    return 72.0;                       // Extra grande
  }

  /// Tamanho do ícone dentro do container
  static double getIconSize(BuildContext context) {
    return getIconContainerSize(context) * 0.5;
  }

  /// Verifica se está em portrait
  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  /// Verifica se está em landscape
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// Verifica se é tela pequena (< 360px)
  static bool isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < 360;
  }

  /// Verifica se é tela normal (360-600px)
  static bool isNormalScreen(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 360 && width < 600;
  }

  /// Verifica se é tablet (>= 600px)
  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= 600;
  }

  /// Altura máxima para bottom sheets
  static double getBottomSheetMaxHeight(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final padding = MediaQuery.of(context).padding;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    // 90% da altura útil (descontando padding superior e teclado)
    return (height - padding.top - keyboardHeight) * 0.9;
  }

  /// Número de colunas para grid/lista
  static int getGridColumns(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return 1;
    if (width < 900) return 2;
    return 3;
  }

  /// Espaçamento entre items em grid
  static double getGridSpacing(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) return 8.0;
    if (width < 600) return 12.0;
    return 16.0;
  }

  /// Calcula a altura de um campo de texto responsivo
  static double getTextFieldHeight(BuildContext context) {
    return ResponsiveUtil.isSmallScreen(context) ? 44.0 : 48.0;
  }

  /// Text scale factor responsivo (para quando não quiser usar TextTheme)
  static double getTextScaleFactor(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) return 0.9;   // Um pouco menor em telas pequenas
    if (width < 600) return 1.0;   // Normal
    return 1.05;                   // Um pouco maior em tablets
  }

  /// Toma decisão entre layout horizontal ou vertical baseado na tela
  static bool shouldUseHorizontalLayout(BuildContext context) {
    // Usa horizontal se for landscape OU se for tablet em portrait
    return MediaQuery.of(context).orientation == Orientation.landscape ||
        MediaQuery.of(context).size.width >= 900;
  }

  /// Retorna valores diferentes baseado no breakpoint
  static T getByBreakpoint<T>({
    required BuildContext context,
    required T small,      // < 360px
    required T normal,     // 360-600px
    required T tablet,     // 600-900px
    required T desktop,    // >= 900px
  }) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) return small;
    if (width < 600) return normal;
    if (width < 900) return tablet;
    return desktop;
  }

  /// Calcula spacing dinâmico para Row/Column
  static Widget getDynamicSpacer(BuildContext context) {
    final spacing = getGridSpacing(context);
    return SizedBox(width: spacing, height: spacing);
  }

  /// Widget para usar em Row para espaçamento horizontal
  static Widget horizontalSpacer(BuildContext context) {
    return SizedBox(width: getGridSpacing(context));
  }

  /// Widget para usar em Column para espaçamento vertical
  static Widget verticalSpacer(BuildContext context) {
    return SizedBox(height: getGridSpacing(context));
  }

  /// Calcula margem segura considerando notch/Dynamic Island
  static EdgeInsets getSafeAreaMargin(BuildContext context) {
    final padding = MediaQuery.of(context).padding;
    final viewInsets = MediaQuery.of(context).viewInsets;

    return EdgeInsets.only(
      top: padding.top > 0 ? padding.top : 16,
      bottom: padding.bottom > 0 ? padding.bottom : 0,
      left: padding.left > 0 ? padding.left : 16,
      right: padding.right > 0 ? padding.right : 16,
    );
  }

  /// Widget helper para ícones em containers
  /// Uso: ResponsiveUtil.responsiveIconContainer(context, Icons.shopping_cart)
  static Widget responsiveIconContainer({
    required BuildContext context,
    required IconData icon,
    Color backgroundColor = const Color(0xFFF5F5F7),
    Color iconColor = const Color(0xFF1B4965),
  }) {
    final size = ResponsiveUtil.getIconContainerSize(context);
    final iconSize = ResponsiveUtil.getIconSize(context);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(size * 0.2),
      ),
      child: Icon(
        icon,
        color: iconColor,
        size: iconSize,
      ),
    );
  }
}

/// Extension em BuildContext para acessar responsive utils facilmente
extension ResponsiveExtension on BuildContext {
  bool get isSmallScreen => ResponsiveUtil.isSmallScreen(this);
  bool get isNormalScreen => ResponsiveUtil.isNormalScreen(this);
  bool get isTablet => ResponsiveUtil.isTablet(this);
  bool get isPortrait => ResponsiveUtil.isPortrait(this);
  bool get isLandscape => ResponsiveUtil.isLandscape(this);

  double get responsivePadding => ResponsiveUtil.getResponsivePadding(this);
  double get iconContainerSize =>
      ResponsiveUtil.getIconContainerSize(this);
  double get iconSize => ResponsiveUtil.getIconSize(this);
  double get gridSpacing => ResponsiveUtil.getGridSpacing(this);
  double get textFieldHeight => ResponsiveUtil.getTextFieldHeight(this);

  EdgeInsets get safeAreaMargin => ResponsiveUtil.getSafeAreaMargin(this);
}
