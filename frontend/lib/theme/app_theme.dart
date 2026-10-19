import 'package:flutter/material.dart';

import 'app_spacing.dart';
import 'app_typography.dart';
import 'tokens/app_colors_semantic.dart';
import 'tokens/app_primitives.dart';

/// Camada 3 do Design System: TOKENS DE COMPONENTE, via [ThemeData].
///
/// ATENCAO: este tema NAO esta ligado ao `MaterialApp` — o tema global em
/// `main.dart` continua intacto para preservar as telas ainda nao
/// redesenhadas. As telas redesenhadas aplicam este tema localmente atraves
/// de `AppScreenScaffold`, que envolve a subarvore num `Theme`.
abstract final class AppTheme {
  static ThemeData get light {
    const colorScheme = ColorScheme.light(
      primary: AppSemanticColors.actionPrimary,
      onPrimary: AppSemanticColors.onAction,
      primaryContainer: AppSemanticColors.actionPrimarySubtle,
      onPrimaryContainer: AppPrimitives.blue700,
      secondary: AppSemanticColors.moduleAi,
      onSecondary: AppPrimitives.white,
      surface: AppSemanticColors.surface,
      onSurface: AppSemanticColors.textPrimary,
      surfaceContainerLowest: AppSemanticColors.surface,
      surfaceContainerLow: AppSemanticColors.background,
      surfaceContainer: AppSemanticColors.surfaceSubtle,
      onSurfaceVariant: AppSemanticColors.textSecondary,
      outline: AppSemanticColors.border,
      outlineVariant: AppSemanticColors.borderStrong,
      error: AppSemanticColors.feedbackError,
      onError: AppPrimitives.white,
      errorContainer: AppSemanticColors.feedbackErrorSubtle,
      onErrorContainer: AppSemanticColors.onFeedbackError,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: AppTypography.fontFamily,
      // O Flutter aplica VisualDensity.compact por padrao em web/desktop, o
      // que tira 8dp dos minimos (botao de 48 vira 40). O Design System exige
      // 48dp em qualquer plataforma, entao a densidade e fixada aqui.
      visualDensity: VisualDensity.standard,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      scaffoldBackgroundColor: AppSemanticColors.background,
      textTheme: _textTheme,
      filledButtonTheme: _filledButtonTheme,
      outlinedButtonTheme: _outlinedButtonTheme,
      textButtonTheme: _textButtonTheme,
      inputDecorationTheme: _inputDecorationTheme,
      cardTheme: _cardTheme,
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppSemanticColors.actionPrimary,
        foregroundColor: AppSemanticColors.onAction,
        elevation: 4,
        highlightElevation: 6,
        shape: CircleBorder(),
      ),
      dividerTheme: const DividerThemeData(
        color: AppSemanticColors.border,
        thickness: 1,
        space: 1,
      ),
      iconTheme: const IconThemeData(
        color: AppSemanticColors.textSecondary,
        size: AppSizes.iconLg,
      ),
    );
  }

  // Tipografia
  static const TextTheme _textTheme = TextTheme(
    displayLarge: AppTypography.displayLarge,
    displayMedium: AppTypography.displayMedium,
    headlineMedium: AppTypography.headlineMedium,
    headlineSmall: AppTypography.headlineSmall,
    titleMedium: AppTypography.titleMedium,
    titleSmall: AppTypography.titleSmall,
    bodyLarge: AppTypography.bodyLarge,
    bodyMedium: AppTypography.bodyMedium,
    bodySmall: AppTypography.bodySmall,
    labelLarge: AppTypography.labelLarge,
    labelMedium: AppTypography.labelMedium,
    labelSmall: AppTypography.labelSmall,
  );

  // Botao primario: altura 48, radius 12.
  static final FilledButtonThemeData _filledButtonTheme = FilledButtonThemeData(
    style: ButtonStyle(
      minimumSize: const WidgetStatePropertyAll(
        Size.fromHeight(AppSizes.control),
      ),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: AppPrimitives.space5),
      ),
      textStyle: const WidgetStatePropertyAll(AppTypography.labelLarge),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
        ),
      ),
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return AppSemanticColors.actionDisabled;
        }
        if (states.contains(WidgetState.pressed) ||
            states.contains(WidgetState.hovered)) {
          return AppSemanticColors.actionPrimaryHover;
        }
        return AppSemanticColors.actionPrimary;
      }),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return AppSemanticColors.onActionDisabled;
        }
        return AppSemanticColors.onAction;
      }),
      elevation: const WidgetStatePropertyAll(0),
      // Foco sempre visivel (WCAG 2.2 AA, criterio 2.4.11).
      side: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.focused)) {
          return const BorderSide(color: AppSemanticColors.focusRing, width: 2);
        }
        return null;
      }),
    ),
  );

  // Botao secundario / outlined.
  static final OutlinedButtonThemeData _outlinedButtonTheme =
      OutlinedButtonThemeData(
    style: ButtonStyle(
      minimumSize: const WidgetStatePropertyAll(
        Size.fromHeight(AppSizes.control),
      ),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: AppPrimitives.space5),
      ),
      textStyle: const WidgetStatePropertyAll(AppTypography.labelLarge),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
        ),
      ),
      backgroundColor: const WidgetStatePropertyAll(AppSemanticColors.surface),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return AppSemanticColors.onActionDisabled;
        }
        return AppSemanticColors.textPrimary;
      }),
      side: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return const BorderSide(color: AppSemanticColors.border);
        }
        if (states.contains(WidgetState.focused)) {
          return const BorderSide(color: AppSemanticColors.focusRing, width: 2);
        }
        return const BorderSide(
          color: AppSemanticColors.textPrimary,
          width: 1.5,
        );
      }),
    ),
  );

  static final TextButtonThemeData _textButtonTheme = TextButtonThemeData(
    style: ButtonStyle(
      minimumSize: const WidgetStatePropertyAll(Size(0, AppSizes.control)),
      textStyle: const WidgetStatePropertyAll(AppTypography.titleSmall),
      foregroundColor: const WidgetStatePropertyAll(AppSemanticColors.textLink),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.chip),
        ),
      ),
    ),
  );

  // Input: altura 48, radius 12.
  static final InputDecorationTheme _inputDecorationTheme =
      InputDecorationTheme(
    filled: true,
    fillColor: AppSemanticColors.surface,
    hintStyle: AppTypography.bodyMedium.copyWith(
      color: AppSemanticColors.textSecondary,
    ),
    labelStyle: AppTypography.labelMedium.copyWith(
      color: AppSemanticColors.textSecondary,
    ),
    contentPadding: const EdgeInsets.symmetric(
      horizontal: AppPrimitives.space4,
      vertical: AppPrimitives.space3,
    ),
    constraints: const BoxConstraints(minHeight: AppSizes.control),
    border: _inputBorder(AppSemanticColors.border),
    enabledBorder: _inputBorder(AppSemanticColors.border),
    focusedBorder: _inputBorder(AppSemanticColors.focusRing, width: 2),
    errorBorder: _inputBorder(AppSemanticColors.feedbackError),
    focusedErrorBorder: _inputBorder(AppSemanticColors.feedbackError, width: 2),
    errorStyle: AppTypography.bodySmall.copyWith(
      color: AppSemanticColors.onFeedbackError,
    ),
  );

  static OutlineInputBorder _inputBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.control),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  // Card: radius 16.
  static final CardThemeData _cardTheme = CardThemeData(
    color: AppSemanticColors.surface,
    elevation: 0,
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.card),
    ),
  );
}
